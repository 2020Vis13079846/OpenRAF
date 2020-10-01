//
//  raflib.hpp
//  OpenRAF
//
//  Created by Ivan Nikolsky on 2020.
//  Copyright © 2020 Ivan Nikolsky. All rights reserved.
//

void start_attack(std::string object_path, std::string attack, int ignore_vps) {
    if (attack == "openraf_ars") {
        std::string vps_string;
        std::string ars_string;
        std::string clean_string;
        std::string atk_string;

        if (ignore_vps == 0) {
            std::cout << "Starting VPS ..." << std::endl;
            vps_string.append("ruby ");
            vps_string.append(object_path);
            vps_string.append("/vps/vps.rb");
            std::system(vps_string);
        }

        // ========================================= \\

        snprintf(atk_string, sizeof(atk_string), "ruby %s/atk/atk.rb", object_path);
        system(atk_string);
        
        // ========================================= \\
        
        printf("Starting OpenRAF ARS ...\n");
        snprintf(ars_string, sizeof(ars_string), "perl %s/ars/ars.pl", object_path);
        system(ars_string);

        // ========================================= \\
        
        if (ignore_vps == 0) {
            snprintf(clean_string, sizeof(clean_string), "rm -rf %s/vps/*.txt", object_path);
            system(clean_string);
            system("killall ngrok >/dev/null");
        }
        
        // ========================================= \\
        
    } else {
        printf("Invalid attack: %s!\n", attack);
    }
}

void help() {
    // Just print help
    
    printf("Usage: openraf [option] <arguments> <flags>\n");
    printf("\n");
    printf("Basic options:\n");
    printf("  -h, --help     Show help and exit.\n");
    printf("  -v, --version  Show OpenRAF version.\n");
    printf("\n");
    printf("Attack options:\n");
    printf("  -a, --attack <attack>  Start specified attack.\n");
    printf("\n");
    printf("Attack flags:\n");
    printf("  --ignore-vps  Ignore VPS, start attack localy.\n");
    printf("\n");
    printf("Backdoor options:\n");
    printf("  -b, --backdoor <backdoor>  Generate specified backdoor.\n");
    printf("\n");
    printf("Backdoor flags:\n");
    printf("  -o, --output <output_path>  Output backdoor to the specified path.\n");
    printf("\n");
    printf("Examples:\n");
    printf(" # openraf --attack openraf_ars\n");
    printf(" # openraf --attack openraf_ars --ignore-vps\n");
    printf(" # openraf --backdoor openraf_ars -o /tmp/backdoor.pl\n");
}
