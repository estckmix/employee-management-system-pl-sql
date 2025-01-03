-- Create the necessary database objects for the Employee Management System

-- 1. Create the EMPLOYEES table to store employee information
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,                 -- Unique ID for each employee
    first_name VARCHAR2(50),                   -- Employee's first name
    last_name VARCHAR2(50),                    -- Employee's last name
    department_id NUMBER,                      -- Department assigned to the employee
    salary NUMBER(10, 2),                      -- Employee's salary
    hire_date DATE DEFAULT SYSDATE,            -- Date the employee was hired
    performance_rating NUMBER(2) DEFAULT 0     -- Employee's performance rating (1-10 scale)
);

-- 2. Create the DEPARTMENTS table to store department details
CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,          -- Unique ID for each department
    department_name VARCHAR2(50),              -- Name of the department
    manager_id NUMBER                          -- Manager of the department
);

-- Insert sample data into DEPARTMENTS
INSERT INTO departments (department_id, department_name, manager_id)
VALUES (1, 'HR', NULL);
INSERT INTO departments (department_id, department_name, manager_id)
VALUES (2, 'IT', NULL);
INSERT INTO departments (department_id, department_name, manager_id)
VALUES (3, 'Finance', NULL);

COMMIT;

-- 3. Create a sequence to generate unique employee IDs
CREATE SEQUENCE emp_seq
    START WITH 1
    INCREMENT BY 1;

-- Create PL/SQL procedures and functions for the Employee Management System

-- Procedure to add a new employee
CREATE OR REPLACE PROCEDURE add_employee (
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_department_id IN NUMBER,
    p_salary IN NUMBER
)
IS
    v_emp_id NUMBER;
BEGIN
    -- Generate a unique employee ID using the sequence
    v_emp_id := emp_seq.NEXTVAL;

    -- Insert the new employee into the EMPLOYEES table
    INSERT INTO employees (emp_id, first_name, last_name, department_id, salary)
    VALUES (v_emp_id, p_first_name, p_last_name, p_department_id, p_salary);

    DBMS_OUTPUT.PUT_LINE('Employee added successfully with ID: ' || v_emp_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error adding employee: ' || SQLERRM);
END;
/

-- Procedure to update an employee's information
CREATE OR REPLACE PROCEDURE update_employee (
    p_emp_id IN NUMBER,
    p_salary IN NUMBER,
    p_department_id IN NUMBER
)
IS
BEGIN
    -- Update the employee record
    UPDATE employees
    SET salary = p_salary,
        department_id = p_department_id
    WHERE emp_id = p_emp_id;

    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Employee updated successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating employee: ' || SQLERRM);
END;
/

-- Function to calculate annual salary of an employee
CREATE OR REPLACE FUNCTION calculate_annual_salary (
    p_emp_id IN NUMBER
) RETURN NUMBER
IS
    v_annual_salary NUMBER;
BEGIN
    -- Calculate annual salary
    SELECT salary * 12 INTO v_annual_salary
    FROM employees
    WHERE emp_id = p_emp_id;

    RETURN v_annual_salary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating salary: ' || SQLERRM);
        RETURN NULL;
END;
/

-- Procedure to generate a performance report
CREATE OR REPLACE PROCEDURE generate_performance_report IS
    CURSOR emp_cursor IS
        SELECT emp_id, first_name, last_name, performance_rating
        FROM employees
        ORDER BY performance_rating DESC;

    v_emp_record emp_cursor%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Employee Performance Report:');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');

    OPEN emp_cursor;

    LOOP
        FETCH emp_cursor INTO v_emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_record.emp_id || 
                             ' | Name: ' || v_emp_record.first_name || ' ' || v_emp_record.last_name ||
                             ' | Performance: ' || v_emp_record.performance_rating);
    END LOOP;

    CLOSE emp_cursor;
END;
/

-- Usage examples
BEGIN
    -- Add new employees
    add_employee('John', 'Doe', 2, 6000);
    add_employee('Jane', 'Smith', 3, 7500);

    -- Update employee information
    update_employee(1, 6500, 2);

    -- Calculate annual salary
    DBMS_OUTPUT.PUT_LINE('Annual Salary: ' || calculate_annual_salary(1));

    -- Generate a performance report
    generate_performance_report;
END;
/
