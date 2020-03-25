//
//  SLPunchCardStatisticsModel.swift
//  ZGYM
//
//  Created by hnsl_mac on 2019/12/16.
//  Copyright © 2019 hnsl_mac. All rights reserved.
//

import Foundation
import ObjectMapper

class SLPunchCardStatisticsModel : NSObject, Mappable{

    var clockInListTopResponseList : [ClockInListTopResponseList]?
    var currentClockInDayNo : Int?
    var currentClockInPeopleCount : Int?
    var currentClockInTotalCount : Int?
    var totalDay : Int?


    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        currentClockInPeopleCount <- map["currentClockInPeopleCount"]
        currentClockInTotalCount <- map["currentClockInTotalCount"]
        clockInListTopResponseList <- map["clockInListTopResponseList"]
        currentClockInDayNo <- map["currentClockInDayNo"]
        totalDay <- map["totalDay"]
        
    }
}

class ClockInListTopResponseList : NSObject, Mappable{
    var avatar : String?
    var custodianId : Int?
    var dayCount : Int?
    var realName : String?
    var childrenId : Int?
    var topNo : Int?

    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        avatar <- map["avatar"]
        custodianId <- map["custodianId"]
        dayCount <- map["dayCount"]
        realName <- map["realName"]
        childrenId <- map["childrenId"]
        topNo <- map["topNo"]
        
    }
}
