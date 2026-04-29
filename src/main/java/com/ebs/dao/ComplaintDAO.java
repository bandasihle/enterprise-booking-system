package com.ebs.dao;

import com.ebs.config.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/*
 DAO class responsible for handling
 complaint related database operations.
*/

public class ComplaintDAO {

    public int getTotalComplaints() {

        int count = 0;

        try {

            Connection conn = DatabaseConnection.getConnection();

            String sql = "SELECT COUNT(*) FROM complaints";

            PreparedStatement ps = conn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                count = rs.getInt(1);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return count;

    }

}