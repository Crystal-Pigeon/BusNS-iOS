//
//  ThemeMode.swift
//  BusNS
//
//  Created by Marko Popić on 11/7/19.
//  Copyright © 2019 Crystal Pigeon. All rights reserved.
//

import Foundation

public enum ThemeMode: Int {
    case light
    case dark
    case auto
    var description: String {
        switch self {
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .auto:
            return "System"
        }
    }
}

public enum ColorIdentifier: Int {
    case defaultColor
    case themeColor, splashBackgroundColor, backgroundColor, shadowColor, titleColor, navigationBackgroundColor, navigationTintColor, mainScreenTextColor
    case dayIndicatorColor, dayTextColor
    case addButtonBackgroundColor, addButtonTextColor
    case busCell_backgroundColor, busCell_currentHourColor, busCell_extrasColor, busCell_scheduleTextColor, busCell_numberBackgroundColor, busCell_numberTextColor, busCell_lineTextColor, busCell_separatorColor
    case addLinesTable, tableSeparatorColor, addLinesLineColor
    case supportBackgroundColor, supportTitleColor, supportTextColor, supportContactMailColor, supportCopyrightsColor
    case settingsBackgroundColor, settingsMainColor, settingsExplenationColor, settingsLineColor
    case rearrangeFavoritesTable, rearrangeFavoritesLineColor
    case animationTextColor
}
