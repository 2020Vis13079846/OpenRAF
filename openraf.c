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
        if (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0) {
            help();
        } else if (strcmp(argv[1], "--version") == 0 || strcmp(argv[1], "-v") == 0) {
            std::cout << "OpenRAF " << version << std::endl;
        } else if (strcmp(argv[1], "--attack") == 0 || strcmp(argv[1], "-a") == 0) {
            if (argc < 3) {
                std::cout << "Missing <attack> in " << argv[1] << "!" << std::endl;
            } else {
                if (strcmp(argv[2], "openraf_ars") == 0) {
                    if (argc == 4) {
                        if (strcmp(argv[3], "--ignore-vps") == 0) {
                            start_attack(object_path, argv[2], 1);
                        } else {
                            std::cout << "Invalid flag " << argv[3] << " for option " << argv[1] << "!" << std::endl;
                        }
                    } else {
                        start_attack(object_path, argv[2], 0);
                    }
                } else {
                    std::cout << "Invalid attack: " << argv[2] << "!" << std::endl;
                }
            }
        } else if (strcmp(argv[1], "--backdoor") == 0 || strcmp(argv[1], "-b") == 0) {
            if (argc < 3) {
                std::cout << "Missing <backdoor> in " << argv[1] << "!" << std::endl;
            } else {
                if (argc < 4) {
                    if (strcmp(argv[2], "openraf_ars") == 0) {
                        generate_backdoor(object_path, argv[2], "./backdoor.pl");
                    } else {
                        std::cout << "Invalid backdoor: " << argv[2] << "!" << std::endl;
                    }
                } else {
                    if (strcmp(argv[3], "-o") == 0 || strcmp(argv[3], "--output") == 0) {
                        if (strcmp(argv[2], "openraf_ars") == 0) {
                            generate_backdoor(object_path, argv[2], argv[4]);
                        } else {
                            std::cout << "Invalid backdoor: " << argv[2] << "!" << std:endl;
                        }
                    } else {
                        std::cout << "Invalid flag " << argv[3] << " for option " << argv[1] << "!" << std::endl;
                    }
                }
            }
        } else {
            help();
        }
    }
    return 0;
}
