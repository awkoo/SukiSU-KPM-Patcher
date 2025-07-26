#include <iostream>
#include <fstream>
#include <vector>
#include <stdexcept>
#include <cstdint>

void xor_encrypt(const std::string& input_path, 
                const std::string& output_path,
                uint8_t xor_key = 0xAA) {
    std::ifstream in_file(input_path, std::ios::binary);
    if (!in_file) {
        throw std::runtime_error("Failed to open" + input_path);
    }

    std::vector<uint8_t> buffer(
        (std::istreambuf_iterator<char>(in_file)),
        std::istreambuf_iterator<char>());
    
    for (auto& byte : buffer) {
        byte ^= xor_key;
    }

    std::ofstream out_file(output_path, std::ios::binary);
    if (!out_file) {
        throw std::runtime_error("Failed to open" + output_path);
    }
    
    out_file.write(reinterpret_cast<const char*>(buffer.data()), buffer.size());
}

int main(int argc, char* argv[]) {
    try {
        if (argc != 3) {
            std::cerr << "Usage: " << argv[0] << " <Input File> <Output File>\n";
            return 1;
        }
        
        xor_encrypt(argv[1], argv[2]);
        return 0;
    } 
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 2;
    }
}