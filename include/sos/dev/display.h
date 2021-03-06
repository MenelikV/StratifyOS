/* Copyright 2011-2018 Tyler Gilbert; 
 * This file is part of Stratify OS.
 *
 * Stratify OS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Stratify OS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Stratify OS.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 */

/*! \addtogroup DISPLAY Display
 * @{
 *
 *
 * \ingroup IFACE_DEV
 *
 * \details This is the interface for accessing displays.  The driver
 * allows an application to load the video memory pointer as well as the
 * width and height of the device.
 *
 * When an application accesses the LCD, it must issue a HOLD before modifying the
 * memory and a RELEASE when modification is complete.
 *
 * \code
 * int fd;
 * display_info_t attr;
 *
 * fd = open("/dev/lcd0", O_RDWR);
 * ioctl(fd, I_DISPLAY_GETINFO, &attr);
 * ioctl(fd, I_DISPLAY_REFRESH, &attr);
 *  //the display will refresh based on the value of attr.freq (usually in the tens of hertz range)
 * \endcode
 */

/*! \file  */
#ifndef SOS_DEV_DISPLAY_H_
#define SOS_DEV_DISPLAY_H_


#include <stdint.h>

#include "mcu/types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define DISPLAY_VERSION (0x030000)
#define DISPLAY_IOC_CHAR 'D'

enum {
	DISPLAY_PALETTE_PIXEL_FORMAT_1BPP,
	DISPLAY_PALETTE_PIXEL_FORMAT_RGB444,
	DISPLAY_PALETTE_PIXEL_FORMAT_RGB565,
	DISPLAY_PALETTE_PIXEL_FORMAT_RGB666,
	DISPLAY_PALETTE_PIXEL_FORMAT_RGB888
};

typedef struct MCU_PACK {
	u8 r4g4;
	u8 b4r4;
	u8 g4b4;
} display_palette_pixel_format_rgb444_t;

typedef struct MCU_PACK {
	u8 r8;
	u8 b8;
	u8 g8;
} display_palette_pixel_format_rgb888_t;

typedef struct MCU_PACK {
	u8 r6x2;
	u8 b6x2;
	u8 g6x2;
} display_palette_pixel_format_rgb666_t;

typedef struct MCU_PACK {
	u8 r5g3;
	u8 g3b5;
} display_palette_pixel_format_rgb565_t;


/*! \brief Display Palette Attributes
 * \details The display palette converts the bits_per_pixel
 * to a native color. For example, if there are two bits per pixel,
 * the display driver can handle 4 colors. The palette defines how those
 * four colors are mapped to the display.
 */
typedef struct MCU_PACK {
	u8 pixel_format /*! Pixel format of the display (e.g. DISPLAY_PALETTE_PIXEL_FORMAT_RGB565) */;
	u8 count /*! The number of pixel entries in the palette */;
	void * colors /*! A pointer to the colors in the palette */;
} display_palette_t;


/*! \brief Display attributes
 * \details This contains the attributes of a display.
 */
typedef struct MCU_PACK {
	u16 width /*! \brief display width in pixels */;
	u16 height /*! \brief display height in pixels */;
	void * mem /*! \brief A pointer to the shared display memory which is mapped to the screen. */;
	void * scratch_mem /*! \brief A pointer to the shared display memory which is mapped to the screen. */;
	u32 size /*! \brief The size of \a mem in bytes (typically w*h*bits_per_pixel/8) */;
	u16 cols /*! \brief Number of memory 32-bit word columns */;
	u16 rows /*! \brief Number of memory rows */;
	u32 freq /*! \brief This value is R/W and specifies how often the screen can be refreshed */;
	u16 o_flags /*! \brief Display flags (not used) */;
	u16 bits_per_pixel /*! The number of bits in each pixel: 1, 2, 4, 8, 16, 24, or 32 */;
	u16 margin_left /*! \brief Left margin */;
	u16 margin_right /*! \brief Right margin */;
	u16 margin_top /*! \brief Top margin */;
	u16 margin_bottom /*! \brief Bottom margin */;
	u32 resd[8];
} display_info_t;

#define I_DISPLAY_GETVERSION _IOCTL(DISPLAY_IOC_CHAR, I_MCU_GETVERSION)


/*! \details This request gets the attributes of the device.
 *
 * Example:
 * \code
 * display_info_t info;
 * ioctl(fildes, I_DISPLAY_GETINFO, &info);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_GETINFO _IOCTLR(DISPLAY_IOC_CHAR, 0, display_info_t)

/*! \details This request clears the LCD.  This does not
 * affect the video memory.  This is only supported on
 * devices that include a way to clear the memory using
 * a hardware command.
 *
 * Example:
 * \code
 * ioctl(fildes, I_DISPLAY_CLEAR);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_CLEAR _IOCTL(DISPLAY_IOC_CHAR, 1)

/*! \details This request tells the driver to update the display
 * as soon as possible.
 *
 * Example:
 * \code
 * ioctl(fildes, I_DISPLAY_REFRESH);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_REFRESH _IOCTL(DISPLAY_IOC_CHAR, 2)

/*! \details This request initializes the LCD.  This request
 * is normally performed by the system meaning an application
 * will not typically call this command.
 *
 * Example:
 * \code
 * ioctl(fildes, I_DISPLAY_INIT);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_INIT _IOCTL(DISPLAY_IOC_CHAR, 3)

/*! \details This turns on the LCD so that an image is shown.
 *
 * Example:
 * \code
 * ioctl(fildes, I_DISPLAY_ENABLE);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_ENABLE _IOCTL(DISPLAY_IOC_CHAR, 4)

/*! \details This turns off the LCD so that no image is shown.
 *
 * Example:
 * \code
 * ioctl(fildes, I_DISPLAY_DISABLE);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_DISABLE _IOCTL(DISPLAY_IOC_CHAR, 5)

/*! \details Returns a positive value if the display is busy.
 *
 * Example:
 * \code
 * if( ioctl(fildes, I_DISPLAY_ISBUSY) > 0 ){
 * 	//display is busy refreshing -- don't modify the display memory while display is busy
 * }
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_ISBUSY _IOCTL(DISPLAY_IOC_CHAR, 6)

/*! \details Gets the palette attributes of the display.
 *
 * Example:
 * \code
 * display_palette_t palette;
 * ioctl(fildes, I_DISPLAY_GETPALETTE, &palette);
 * \endcode
 * \hideinitializer
 */
#define I_DISPLAY_GETPALETTE _IOCTLR(DISPLAY_IOC_CHAR, 7, display_palette_t)


#define I_DISPLAY_TOTAL 8

/*! @} */

#ifdef __cplusplus
}
#endif


#endif /* SOS_DEV_DISPLAY_H_ */
