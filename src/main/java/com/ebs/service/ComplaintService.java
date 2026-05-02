package com.ebs.service;

import com.ebs.dao.ComplaintDAO;

/*
 Service layer for complaints.
*/

public class ComplaintService {

    ComplaintDAO complaintDAO = new ComplaintDAO();

    public int getComplaintCount() {

        return complaintDAO.getTotalComplaints();

    }

}