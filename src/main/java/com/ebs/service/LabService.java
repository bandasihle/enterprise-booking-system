package com.ebs.service;

import com.ebs.dao.LabDAO;
import com.ebs.models.Lab;

/*
 * Service layer for Lab operations.
 * Sits between the Servlet (controller) and LabDAO.
 * Contains business logic before hitting the database.
 */
public class LabService {

    // DAO instance used to talk to the database
    LabDAO labDAO = new LabDAO();

    /*
     * Creates a new lab and saves it to the database.
     * 
     * @param labName  - name of the lab e.g. "Lab 5"
     * @param building - building where the lab is e.g. "Block A"
     * @param capacity - total number of PCs/seats
     * @return true if saved successfully, false if failed
     */
    public boolean createLab(String labName, String building, int capacity) {

        // Build the Lab object
        Lab lab = new Lab(labName, building, capacity);

        // Pass to DAO to insert into database
        return labDAO.addLab(lab);
    }
}