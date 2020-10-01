//
//  libbackdoor.h
//  OpenRAF
//
//  Created by Ivan Nikolsky on 2020.
//  Copyright © 2020 Ivan Nikolsky. All rights reserved.
//

void generate_backdoor(char object_path[], char backdoor[], char output[]) {
    char backdoor_string[100];
    if (strcmp(backdoor, "openraf_ars") == 0) {
        printf("Generating openraf_ars backdoor ...\n");
        snprintf(backdoor_string, sizeof(backdoor_string), "cp %s/ars/backdoor.pl %s", object_path, output);
        system(backdoor_string);
        printf("Backdoor saved to %s\n", output);
    } else {
        printf("Invalid backdoor: %s", backdoor);
    }
}
