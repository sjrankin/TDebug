//
//  CommStatic.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Comm
{
    /// Create a time-stamp string from the passed date.
    ///
    /// - Parameters:
    ///   - FromDate: The date from which a string will be created.
    ///   - TimeSeparator: Separator to use for the time part.
    /// - Returns: String in the format: dd MMM yyyy HH:MM:SS
    public static func MakeTimeStamp(FromDate: Date, TimeSeparator: String = ":") -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: FromDate)
        let Month = Cal.component(.month, from: FromDate)
        let MonthName = ["Zero", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][Month]
        let Day = Cal.component(.day, from: FromDate)
        let DatePart = "\(Year)-\(MonthName)-\(Day) "
        let Hour = Cal.component(.hour, from: FromDate)
        var HourString = String(describing: Hour)
        if Hour < 10
        {
            HourString = "0" + HourString
        }
        let Minute = Cal.component(.minute, from: FromDate)
        var MinuteString = String(describing: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        let Second = Cal.component(.second, from: FromDate)
        var Result = HourString + TimeSeparator + MinuteString
        var SecondString = String(describing: Second)
        if Second < 10
        {
            SecondString = "0" + SecondString
        }
        Result = Result + TimeSeparator + SecondString
        return DatePart + Result
    }
}
