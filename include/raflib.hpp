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
            std::system(vps_string.c_str());
        }

        atk_string.append("ruby");
        atk_string.append(object_path);
        atk_string.append("/atk/atk.rb")
        std::system(atk_string.c_str());
        
        std::cout << "Starting OpenRAF ARS ..." << std::endl;
        ars_string.append("perl ");
        ars_string.append(object_path);
        ars_string.append("/ars/ars.pl");
        std::system(ars_string.c_str());
        
        if (ignore_vps == 0) {
            clean_string.append("rm -rf ");
            clean_string.append(object_path);
            clean_string.append("/vps/*.txt");
            std::system(clean_string.c_str());
            std::system("killall ngrok >/dev/null");
        }   
    } else {
        std::cout << "Invalid attack: " << attack << "!" << std::endl;
    }
}

void help() {
    std::cout << "Usage: openraf [option] <arguments> <flags>" << std::endl;
    std::cout << std::endl;
    std::cout << "Basic options:" << std::endl;
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
