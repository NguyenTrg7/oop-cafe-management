#include "Account.h"
#include <QCoreApplication> // 🌟 Thêm thư viện Qt để lấy đường dẫn app
#include <fstream>          // Thư viện đọc/ghi file chuẩn C++
#include <iostream>         // Thư viện in ra màn hình (cout)
#include <sstream>          // Thư viện cắt chuỗi chuẩn C++

Account::Account(QObject *parent)
    : QObject(parent)
{
    // Lấy đường dẫn thư mục chứa file chạy (.exe) và ghép với "/accounts.csv"
    QString absolutePath = QCoreApplication::applicationDirPath() + "/accounts.csv";

    // Ép kiểu về std::string để sử dụng với C++ chuẩn
    m_csvFilePath = absolutePath.toStdString();

    initFile();
}

Account::~Account() {}

// ========================================================
// 🛠️ KHỞI TẠO FILE
// ========================================================
void Account::initFile()
{
    // Mở file ở chế độ ios::app (Ghi tiếp). Nếu file chưa có, C++ sẽ tự động tạo mới.
    std::ofstream file(m_csvFilePath, std::ios::app);
    if (file.is_open()) {
        file.close();
    } else {
        std::cout << "Loi: Khong the tao file CSV tai: " << m_csvFilePath << "\n";
    }
}

// ========================================================
// 🔐 LOGIC ĐĂNG NHẬP (C++ Chuẩn)
// ========================================================
bool Account::authenticate(const QString &username, const QString &password)
{
    // 1. Dịch dữ liệu từ QML (QString) sang C++ (std::string)
    std::string inputUser = username.toStdString();
    std::string inputPass = password.toStdString();

    // 2. Mở file để ĐỌC (ifstream)
    std::ifstream file(m_csvFilePath);
    if (!file.is_open()) {
        return false;
    }

    std::string line;
    // 3. Đọc từng dòng cho đến hết file
    while (std::getline(file, line)) {
        // Bỏ qua nếu gặp dòng trống
        if (line.empty())
            continue;

        // 🌟 Xóa ký tự \r ở cuối dòng (nếu chạy trên hệ điều hành Windows)
        if (!line.empty() && line.back() == '\r') {
            line.pop_back();
        }

        std::stringstream ss(line);
        std::string dbUser, dbPass;

        // 4. Cắt chuỗi bằng dấu phẩy ','
        if (std::getline(ss, dbUser, ',') && std::getline(ss, dbPass)) {
            // 5. So sánh dữ liệu trong file với dữ liệu người dùng gõ
            if (dbUser == inputUser && dbPass == inputPass) {
                file.close();
                return true; // Khớp 100% -> Đăng nhập thành công!
            }
        }
    }

    file.close();
    return false; // Chạy hết vòng lặp mà không thấy -> Báo sai!
}

// ========================================================
// ❄️ LOGIC ĐĂNG KÝ (C++ Chuẩn)
// ========================================================
bool Account::registerAccount(const QString &username, const QString &password)
{
    // 1. Dịch dữ liệu
    std::string inputUser = username.toStdString();
    std::string inputPass = password.toStdString();

    // =======================================
    // BƯỚC 1: Đọc file để kiểm tra tài khoản trùng
    // =======================================
    std::ifstream inFile(m_csvFilePath);
    if (inFile.is_open()) {
        std::string line;
        while (std::getline(inFile, line)) {
            if (line.empty())
                continue;

            // 🌟 Xóa ký tự \r trước khi cắt chuỗi
            if (!line.empty() && line.back() == '\r') {
                line.pop_back();
            }

            std::stringstream ss(line);
            std::string dbUser;

            // Chỉ cần lấy phần chữ trước dấu phẩy (tên tài khoản) để kiểm tra
            if (std::getline(ss, dbUser, ',')) {
                if (dbUser == inputUser) {
                    inFile.close();
                    return false; // ❌ Thất bại: Tài khoản đã bị trùng!
                }
            }
        }
        inFile.close();
    }

    // =======================================
    // BƯỚC 2: Ghi tài khoản mới vào cuối file
    // =======================================
    // Mở file ở chế độ ios::app (Append - Ghi nối tiếp vào đuôi file)
    std::ofstream outFile(m_csvFilePath, std::ios::app);
    if (outFile.is_open()) {
        // Ghi theo định dạng: user,pass rồi xuống dòng (\n)
        outFile << inputUser << "," << inputPass << "\n";
        outFile.close();
        return true; // ✅ Đăng ký thành công!
    }

    return false; // Lỗi không mở được file
}