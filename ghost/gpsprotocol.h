/*

   uc-ghost
   Copyright [2016-2017] [Nuno Anselmo]

   This file is part of the uc-ghost source code.

   uc-ghost is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   uc-ghost source code is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with uc-ghost source code. If not, see <http://www.gnu.org/licenses/>.

   uc-ghost is modified from ent-ghost (https://github.com/uakfdotb/ent-ghost)
   ent-ghost is Copyright [2011-2013] [Jack Lu]

   ent-ghost is modified from GHost++ (http://ghostplusplus.googlecode.com/)
   GHost++ is Copyright [2008] [Trevor Hogan]

 */

#ifndef GPSPROTOCOL_H
#define GPSPROTOCOL_H

//
// CGameProtocol
//

#define GPS_HEADER_CONSTANT     248

#define REJECTGPS_INVALID     1
#define REJECTGPS_NOTFOUND      2

class CGPSProtocol
{
public:
enum Protocol {
  GPS_INIT        = 1,
  GPS_RECONNECT     = 2,
  GPS_ACK         = 3,
  GPS_REJECT        = 4
};

CGPSProtocol( );
~CGPSProtocol( );

// receive functions

// send functions

BYTEARRAY SEND_GPSC_INIT( uint32_t version );
BYTEARRAY SEND_GPSC_RECONNECT( unsigned char PID, uint32_t reconnectKey, uint32_t lastPacket );
BYTEARRAY SEND_GPSC_ACK( uint32_t lastPacket );

BYTEARRAY SEND_GPSS_INIT( uint16_t reconnectPort, unsigned char PID, uint32_t reconnectKey, unsigned char numEmptyActions );
BYTEARRAY SEND_GPSS_RECONNECT( uint32_t lastPacket );
BYTEARRAY SEND_GPSS_ACK( uint32_t lastPacket );
BYTEARRAY SEND_GPSS_REJECT( uint32_t reason );

// other functions

private:
bool AssignLength( BYTEARRAY &content );
bool ValidateLength( BYTEARRAY &content );
};

#endif
