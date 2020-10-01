//
//  openraf.cc
//  OpenRAF
//
//  Created by Ivan Nikolsky on 2020.
//  Copyright © 2020 Ivan Nikolsky. All rights reserved.
//

#include <iostream>
#include <cstdlib>
#include <cstring>

#include "include/raflib.hpp"
#include "include/libbackdoor.hpp"

int main(int argc, char *argv[]) {
    std::string object_path = "/usr/local/share/OpenRAF";
    std::string version = "v2.0";
    if (argc < 2) {
        help();
    } else {
        std::string arg1(argv[1]);
        if (arg1 == "--help" || arg1 == "-h") {
            help();
        } else if (arg1 == "--version" || arg1 == "-v") {
            std::cout << "OpenRAF " << version << std::endl;
        } else if (arg1 == "--attack" || arg1 == "-a") {
            if (argc < 3) {
                std::cout << "Missing <attack> in " << arg1 << "!" << std::endl;
            } else {
                std::string arg2(argv[2]);
                if (arg2 == "openraf_ars") {
                    if (argc == 4) {
                        std::string arg3(argv[3]);
                        if (arg3 == "--ignore-vps") {
                            start_attack(object_path, arg2, 1);
                        } else {
                            std::cout << "Invalid flag " << arg3 << " for option " << arg1 << "!" << std::endl;
                        }
                    } else {
                        start_attack(object_path, arg2, 0);
                    }
                } else {
                    std::cout << "Invalid attack: " << arg2 << "!" << std::endl;
                }
            }
        } else if (arg1 == "--backdoor" || arg1 == "-b") {
            if (argc < 3) {
                std::cout << "Missing <backdoor> in " << arg1 << "!" << std::endl;
            } else {
                if (argc < 4) {
                    std::string arg2(argv[2]);
                    if (arg2 == "openraf_ars") {
                        generate_backdoor(object_path, arg2, "./backdoor.pl");
                    } else {
                        std::cout << "Invalid backdoor: " << arg2 << "!" << std::endl;
                    }
                } else {
                    std::string arg2(argv[2]);
                    std::string arg3(argv[3]); 
                    if (arg3 == "--output" || arg3 == "-o") {
                        if (arg2 == "openraf_ars") {
                            if (argc < 5) {
                                std::cout << "Missing <output_path> in " << arg3 << "!" << std::endl;
                            } else {
                                std::string arg4(argv[4]);
                                generate_backdoor(object_path, arg2, arg4);
                            }
                        } else {
                            std::cout << "Invalid backdoor: " << arg2 << "!" << std::endl;
                        }
                    } else {
                        std::cout << "Invalid flag " << arg3 << " for option " << arg1 << "!" << std::endl;
                    }
                }
            }
        } else {
            help();
        }
    }
    return 0;
}
