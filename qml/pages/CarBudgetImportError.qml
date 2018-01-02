/**
 * CarBudget, Sailfish application to manage car cost
 *
 * Copyright (C) 2018 Fabien Proriol
 *
 * This file is part of CarBudget.
 *
 * CarBudget is free software: you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * CarBudget is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details. You should have received a copy of the GNU
 * General Public License along with CarBudget. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Matti Viljanen
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.carbudget 1.0

Page {
    property string errorDescription
    allowedOrientations: Orientation.All
    SilicaFlickable {

        VerticalScrollDecorator {}

        anchors.fill: parent

        PageHeader {
            title: qsTr("Error")
        }

        Label {
            anchors.fill: parent
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            text: {
                if(errorDescription === "FILE_EXISTS")
                    return qsTr("Could not import selected file, because the car name chosen already exists.")
                else if(errorDescription === "DB_ERROR")
                    return qsTr("Could not import selected file, because the file is not a valid CarBudet database file.")
                else //if(errorDescription === "UNKNOWN")
                    return qsTr("Could not import selected file. Unknown error.")
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
