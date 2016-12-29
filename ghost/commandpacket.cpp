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

#include "ghost.h"
#include "commandpacket.h"

//
// CCommandPacket
//

CCommandPacket :: CCommandPacket( unsigned char nPacketType, int nID, BYTEARRAY nData ) : m_PacketType( nPacketType ), m_ID( nID ), m_Data( nData )
{

}

CCommandPacket :: ~CCommandPacket( )
{

}
