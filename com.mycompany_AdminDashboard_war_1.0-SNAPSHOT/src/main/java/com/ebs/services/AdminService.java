package com.ebs.services;

import com.ebs.dao.AdminDAO;

/*
 Service Layer

 This layer contains the business logic
 between the controller and DAO layer.
*/

public class AdminService {

    AdminDAO adminDAO = new AdminDAO();

    public int getStudentCount() {

        return adminDAO.getTotalStudents();

    }

}