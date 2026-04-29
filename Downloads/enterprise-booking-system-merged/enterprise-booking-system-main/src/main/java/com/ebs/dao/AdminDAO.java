
package com.ebs.dao;

import com.ebs.config.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/*
 DAO = Data Access Object

 This class interacts with the database
 for all Admin related operations.
*/
public class AdminDAO {

    /*
     Get dashboard statistics
     */
    public int getTotalStudents() {

        int total = 0;

        try {

            Connection conn = DatabaseConnection.getConnection();

            String sql =
                    "SELECT COUNT(*) FROM users WHERE role='STUDENT'";

            PreparedStatement ps = conn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                total = rs.getInt(1);

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return total;
    }

}