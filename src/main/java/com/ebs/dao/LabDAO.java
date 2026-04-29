package com.ebs.dao;

import com.ebs.config.DatabaseConnection;
import com.ebs.models.Lab;

import java.sql.Connection;
import java.sql.PreparedStatement;

/*
 * DAO for labs table
 * Columns used: lab_name, building, capacity
 */
public class LabDAO {

    /*
     * Inserts a new lab into the labs table
     */
    public boolean addLab(Lab lab) {
        boolean success = false;

        try (Connection conn = DatabaseConnection.getConnection()) {

            System.out.println("✅ LabDAO connected to DB");

            String sql = "INSERT INTO labs (lab_name, building, capacity) VALUES (?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, lab.getLabName());
            ps.setString(2, lab.getBuilding());
            ps.setInt(3, lab.getCapacity());

            success = ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("❌ LabDAO Error: " + e.getMessage());
            e.printStackTrace();
        }

        return success;
    }
}