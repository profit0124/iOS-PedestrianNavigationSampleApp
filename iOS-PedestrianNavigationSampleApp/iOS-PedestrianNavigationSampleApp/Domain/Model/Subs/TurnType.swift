//
//  TurnType.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/4/24.
//

import Foundation

enum TurnType: Int {
    case none = 1           // 1~7: No guidance
    
    case goStraight = 11     // 11: Go straight
    case turnLeft = 12       // 12: Turn left
    case turnRight = 13      // 13: Turn right
    case uTurn = 14          // 14: U-turn
    case turnLeft8 = 16      // 16: Turn left at 8 o'clock
    case turnLeft10 = 17     // 17: Turn left at 10 o'clock
    case turnRight2 = 18     // 18: Turn right at 2 o'clock
    case turnRight4 = 19     // 19: Turn right at 4 o'clock
    
    case waypoint = 184       // 184: Waypoint
    case firstWaypoint = 185  // 185: First waypoint
    case secondWaypoint = 186 // 186: Second waypoint
    case thirdWaypoint = 187  // 187: Third waypoint
    case fourthWaypoint = 188 // 188: Fourth waypoint
    case fifthWaypoint = 189  // 189: Fifth waypoint

    case footbridge = 125     // 125: Footbridge
    case underpass = 126      // 126: Underpass
    case stairsEntry = 127    // 127: Enter stairs
    case rampEntry = 128      // 128: Enter ramp
    case stairsAndRamp = 129  // 129: Enter stairs + ramp

    case startingPoint  = 200 // 200: Starting point
    case destination = 201    // 201: Destination
    case crosswalk = 211      // 211: Crosswalk
    case crosswalkLeft = 212  // 212: Left crosswalk
    case crosswalkRight = 213 // 213: Right crosswalk
    case crosswalk8 = 214     // 214: Crosswalk at 8 o'clock
    case crosswalk10 = 215    // 215: Crosswalk at 10 o'clock
    case crosswalk2 = 216     // 216: Crosswalk at 2 o'clock
    case crosswalk4 = 217     // 217: Crosswalk at 4 o'clock
    case elevator = 218       // 218: Elevator
    case temporaryStraight = 233 // 233: Temporary straight
}


extension TurnType {
    func getTitle() -> String {
        switch self {
        case .none:
            "안내없음"
        case .goStraight:
            "직진"
        case .turnLeft:
            "좌회전"
        case .turnRight:
            "우회전"
        case .uTurn:
            "유턴"
        case .turnLeft8:
            "8시 방향 좌회전"
        case .turnLeft10:
            "10시 방향 좌회전"
        case .turnRight2:
            "8시 방향 우회전"
        case .turnRight4:
            "10시 방향 우회전"
        case .waypoint:
            "경유지"
        case .firstWaypoint:
            "첫 번째 경유지"
        case .secondWaypoint:
            "두 번째 경유지"
        case .thirdWaypoint:
            "세 번째 경유지"
        case .fourthWaypoint:
            "네 번째 경우지"
        case .fifthWaypoint:
            "다섯 번째 경유지"
        case .footbridge:
            "육교"
        case .underpass:
            "지하보도"
        case .stairsEntry:
            "계단 진입"
        case .rampEntry:
            "경사로 진입"
        case .stairsAndRamp:
            "계단 + 경사로 진입"
        case .startingPoint:
            "안내시작"
        case .destination:
            "목적지 근처입니다"
        case .crosswalk:
            "횡단보도"
        case .crosswalkLeft:
            "좌측 횡단보도"
        case .crosswalkRight:
            "우측 횡단보도"
        case .crosswalk8:
            "8시 방향 횡단보도"
        case .crosswalk10:
            "10시 방향 횡단보도"
        case .crosswalk2:
            "2시 방향 횡단보도"
        case .crosswalk4:
            "4시 방향 횡단보도"
        case .elevator:
            "엘레베이터"
        case .temporaryStraight:
            "직진 임시"
        }
    }
}
