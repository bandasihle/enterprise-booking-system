package com.ebs.config;

import java.sql.Connection;
import java.sql.DriverManager;

/*
 * Connects the backend to the MySQL database.
 * useSSL=false disables SSL which was causing the keystore error.
 * allowPublicKeyRetrieval=true allows connection without SSL certificates.
 */
public class DatabaseConnection {

    // 🔥 useSSL=false fixes the keystore error
    private static final String URL =
        "jdbc:mysql://localhost:3306/ebs_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String USER = "root";

    // Replace with your actual MySQL password
    private static final String PASSWORD = "30308122";

    public static Connection getConnection() throws Exception {

        Class.forName("com.mysql.cj.jdbc.MysqlDataSource");

        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);

        System.out.println("✅ DB Connected Successfully");

        return conn;
    }
}