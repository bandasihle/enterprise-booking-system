package com.ebs.dao;

import com.ebs.config.DatabaseConnection;
import com.ebs.models.User;

import java.sql.Connection;
import java.sql.PreparedStatement;

/*
 * DAO for users table
 * Handles: addUser, banUser
 */
public class UserDAO {

    /*
     * Inserts a new user into the users table
     */
    public boolean addUser(User user) {
        boolean success = false;

        try (Connection conn = DatabaseConnection.getConnection()) {

            System.out.println("✅ UserDAO connected to DB");

            String sql = "INSERT INTO users (full_name, email, password, role, is_banned, cancellation_count) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            ps.setBoolean(5, false);
            ps.setInt(6, 0);

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("❌ UserDAO Error: " + e.getMessage());
            e.printStackTrace();
        }

        return success;
    }

    /*
     * Bans a user by setting is_banned = true
     */
    public boolean banUser(int userId) {
        boolean success = false;

        try (Connection conn = DatabaseConnection.getConnection()) {

            String sql = "UPDATE users SET is_banned = true WHERE id = ?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("❌ Ban User Error: " + e.getMessage());
            e.printStackTrace();
        }

        return success;
    }

    /*
     * Returns total number of users
     */
    public int getTotalUsers() {
        int count = 0;

        try (Connection conn = DatabaseConnection.getConnection()) {

            java.sql.PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
            java.sql.ResultSet rs = ps.executeQuery();

            if (rs.next()) count = rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
}