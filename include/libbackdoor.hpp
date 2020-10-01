//
//  libbackdoor.hpp
//  OpenRAF
//
//  Created by Ivan Nikolsky on 2020.
//  Copyright © 2020 Ivan Nikolsky. All rights reserved.
//

void generate_backdoor(std::string object_path, std::string backdoor, std::string output) {
    std::string backdoor_string;
    
    if (backdoor == "openraf_ars") {
        std::cout << "Generating openraf_ars backdoor ..." << std::endl;
        backdoor_string.append("cp ");
        backdoor_string.append(object_path);
        backdoor_string.append(" /ars/backdoor.pl ");
        backdoor_string.append(output);
        std::system(backdoor_string);
        std::cout << "Backdoor saved to " << output << "." << std::endl;
    } else {
        std::cout << "Invalid backdoor: " << backdoor << "!" << std::endl;
    }
}
