//
//  sysctlbynameButBetter.swift
//  ballpa1n
//
//  Created by Lakhan Lothiyi on 21/10/2022.
//

import Foundation

func sysctlbynameButBetter(_ str: String) -> String! {
    var size = 0
    sysctlbyname(str, nil, &size, nil, 0)
    var machine = [CChar](repeating: 0,  count: size)
    sysctlbyname(str, &machine, &size, nil, 0)
    if machine.isEmpty { return nil }
    return String(cString: machine)
}
