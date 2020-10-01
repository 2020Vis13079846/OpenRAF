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

#include "include/raflib.h"
#include "include/libbackdoor.h"

int main(int argc, char *argv[]) {
    char object_path[] = "/usr/local/share/OpenRAF";
    char version[] = "v0.0.1a";
    if (argc < 2) {
        help();
    } else {
        if (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0) {
            help();
        } else if (strcmp(argv[1], "--version") == 0 || strcmp(argv[1], "-v") == 0) {
            printf("OpenRAF %s\n", version);
        } else if (strcmp(argv[1], "--attack") == 0 || strcmp(argv[1], "-a") == 0) {
            if (argc < 3) {
                printf("Missing <attack> in %s!\n", argv[1]);
            } else {
                if (strcmp(argv[2], "openraf_ars") == 0) {
                    if (argc == 4) {
                        if (strcmp(argv[3], "--ignore-vps") == 0) {
                            start_attack(object_path, argv[2], 1);
                        } else {
                            printf("Invalid flag %s for option %s!\n", argv[3], argv[1]);
                        }
                    } else {
                        start_attack(object_path, argv[2], 0);
                    }
                } else {
                    printf("Invalid attack: %s!\n", argv[2]);
                }
            }
        } else if (strcmp(argv[1], "--backdoor") == 0 || strcmp(argv[1], "-b") == 0) {
            if (argc < 3) {
                printf("Missing <backdoor> in %s!\n", argv[1]);
            } else {
                if (argc < 4) {
                    if (strcmp(argv[2], "openraf_ars") == 0) {
                        generate_backdoor(object_path, argv[2], "./backdoor.pl");
                    } else {
                        printf("Invalid backdoor: %s!\n", argv[2]);
                    }
                } else {
                    if (strcmp(argv[3], "-o") == 0 || strcmp(argv[3], "--output") == 0) {
                        if (strcmp(argv[2], "openraf_ars") == 0) {
                            generate_backdoor(object_path, argv[2], argv[4]);
                        } else {
                            printf("Invalid backdoor: %s!\n", argv[2]);
                        }
                    } else {
                        printf("Invalid flag %s for option %s!\n", argv[3], argv[1]);
                    }
                }
            }
        } else {
            help();
        }
    }
    return 0;
}
