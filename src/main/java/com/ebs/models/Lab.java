package com.ebs.models;

/*
 * Represents the labs table in ebs_db
 * Columns: ID, lab_name, building, capacity
 */
public class Lab {

    private int id;
    private String labName;
    private String building;
    private int capacity;

    public Lab() {}

    // Constructor for adding a new lab
    public Lab(String labName, String building, int capacity) {
        this.labName = labName;
        this.building = building;
        this.capacity = capacity;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getLabName() { return labName; }
    public void setLabName(String labName) { this.labName = labName; }

    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
}