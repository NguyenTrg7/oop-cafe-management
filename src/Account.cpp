#include "Account.h"
#include <QSqlQuery> // Thư viện để thực thi câu lệnh SQL
#include <QDebug>
#include <QDir>       // Để quản lý đường dẫn file
#include <QStandardPaths> // Để lấy đường dẫn thư mục lưu dữ liệu app an toàn

Account::Account(QObject *parent) : QObject(parent) {
    // Lúc khởi tạo, gọi ngay hàm tạo Database
    if (!initializeDatabase()) {
        qCritical() << "[Database] Không thể khởi tạo hệ thống lưu trữ tài khoản!";
    }
}

Account::~Account() {
    // Đóng database khi app tắt
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool Account::initializeDatabase() {
    qDebug() << "[Database] Đang khởi tạo kết nối...";

    // 1. Định nghĩa loại driver database là SQLite
    m_db = QSqlDatabase::addDatabase("QSQLITE");

    // 2. Định nghĩa tên file và nơi lưu file database trên ổ cứng
    // Chúng ta nên lưu vào thư mục 'AppData' của user để an toàn, không lo bị xóa nhầm
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dbPath);
    if (!dir.exists()) {
        dir.mkpath("."); // Tạo thư mục nếu chưa có
    }

    QString dbName = dbPath + "/giangs_coffee_accounts.db";
    qDebug() << "[Database] File database sẽ được lưu tại:" << dbName;
    m_db.setDatabaseName(dbName);

    // 3. Mở database
    if (!m_db.open()) {
        qDebug() << "[Database] Lỗi không mở được file!" << m_db.lastError().text();
        return false;
    }

    // 4. Tạo bảng 'Accounts' nếu chưa tồn tại
    // Bảng này có 2 cột: username (PRIMARY KEY - khóa chính, duy nhất), password
    QSqlQuery query;
    QString createTableSql = "CREATE TABLE IF NOT EXISTS Accounts ("
                             "username TEXT PRIMARY KEY, "
                             "password TEXT NOT NULL"
                             ")";

    if (!query.exec(createTableSql)) {
        qDebug() << "[Database] Lỗi không tạo được bảng!" << query.lastError().text();
        return false;
    }

    qDebug() << "[Database] Khởi tạo thành công và sẵn sàng!";
    return true;
}

// Logic KIỂM TRA ĐĂNG NHẬP (Dùng SELECT)
bool Account::authenticate(const QString& username, const QString& password) {
    qDebug() << "[Database] Đang kiểm tra đăng nhập cho:" << username;

    if (username.isEmpty() || password.isEmpty()) return false;

    // Sử dụng câu lệnh SELECT để tìm password của username nhập vào
    QSqlQuery query;
    query.prepare("SELECT password FROM Accounts WHERE username = :user");
    query.bindValue(":user", username); // bindValue để chống SQL Injection

    if (!query.exec()) {
        qDebug() << "[Database] Lỗi thực thi truy vấn!" << query.lastError().text();
        return false;
    }

    // Nếu tìm thấy 1 dòng kết quả
    if (query.next()) {
        QString dbPassword = query.value(0).toString(); // Lấy password từ database ra
        // So sánh
        if (dbPassword == password) {
            qDebug() << "[Database] Đăng nhập THÀNH CÔNG cho:" << username;
            return true;
        }
    }

    qDebug() << "[Database] Đăng nhập THẤT BẠI: Sai tài khoản hoặc mật khẩu.";
    return false;
}

// Logic ĐĂNG KÝ TÀI KHOẢN MỚI (Dùng INSERT)
bool Account::registerAccount(const QString& username, const QString& password) {
    qDebug() << "[Database] Đang đăng ký tài khoản mới:" << username;

    if (username.isEmpty() || password.isEmpty()) return false;

    // Sử dụng câu lệnh INSERT để thêm một dòng mới vào bảng Accounts
    QSqlQuery query;
    query.prepare("INSERT INTO Accounts (username, password) VALUES (:user, :pass)");
    query.bindValue(":user", username);
    query.bindValue(":pass", password);

    if (!query.exec()) {
        // Nếu INSERT thất bại, thường là do 'username' đã tồn tại ( PRIMARY KEY )
        qDebug() << "[Database] Lỗi đăng ký (có thể tài khoản đã tồn tại)!" << query.lastError().text();
        return false; // Đăng ký thất bại
    }

    qDebug() << "[Database] Đăng ký THÀNH CÔNG cho tài khoản mới:" << username;
    return true; // Đăng ký thành công
}