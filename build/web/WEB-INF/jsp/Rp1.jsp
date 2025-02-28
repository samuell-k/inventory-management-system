<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.sql.*, java.util.Date, java.util.Calendar" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock In Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 14px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
            color: #666;
        }
        .no-data {
            text-align: center;
            color: #777;
            font-size: 14px;
        }
        .back-button, .print-button {
            display: block;
            width: fit-content;
            margin: 20px auto;
            padding: 10px 20px;
            text-align: center;
            font-size: 16px;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .back-button {
            background-color: #007bff;
        }
        .back-button:hover {
            background-color: #0056b3;
        }
        .print-button {
            background-color: #28a745;
        }
        .print-button:hover {
            background-color: #218838;
        }
        /* Print Media Query */
        @media print {
            .back-button, .print-button {
                display: none;
            }
        }
    </style>
    <script>
        function printPage() {
            window.print();
        }
    </script>
</head>
<body>
<div class="container">
    <h1>Stock In Report</h1>
    
    <form method="GET">
        Filter 
        <select name="filter" onchange="this.form.submit()">
            <option value="all" ${param.filter == 'all' ? 'selected' : ''}>--All--</option>
            <option value="day" ${param.filter == 'day' ? 'selected' : ''}>Daily</option>
            <option value="week" ${param.filter == 'week' ? 'selected' : ''}>Weekly</option>
            <option value="month" ${param.filter == 'month' ? 'selected' : ''}>Monthly</option>
        </select>
    </form>

    <div id="reportResults">
        <% 
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                // Database connection
                conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/inventory", "root", "");

                // Get the filter option from the request
                String filter = request.getParameter("filter");
                String query = "SELECT * FROM stockin";
                
                // Apply filtering based on the selected option
                if ("day".equals(filter)) {
                    query += " WHERE DATE(created_date) = CURDATE()";
                } else if ("week".equals(filter)) {
                    query += " WHERE YEARWEEK(created_date, 1) = YEARWEEK(CURDATE(), 1)";
                } else if ("month".equals(filter)) {
                    query += " WHERE YEAR(created_date) = YEAR(CURDATE()) AND MONTH(created_date) = MONTH(CURDATE())";
                }

                pstmt = conn.prepareStatement(query);
                rs = pstmt.executeQuery();

                if (rs.next()) {
        %>
        <table>
            <thead>
                <tr>
                    <th>Product ID</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Created Date</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Displaying data
                    do {
                        int productId = rs.getInt("product_id");
                        int quantity = rs.getInt("quantity");
                        int price = rs.getInt("price");
                        Date date = rs.getDate("created_date");
                %>
                <tr>
                    <td><%= productId %></td>
                    <td><%= quantity %></td>
                    <td><%= price %></td>
                    <td><%= date %></td>
                </tr>
                <%
                    } while (rs.next());
                %>
            </tbody>
        </table>
        <%
                } else {
        %>
        <p class="no-data">No data available for the selected filter.</p>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <p class="no-data">Error retrieving data: <%= e.getMessage() %></p>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>

    <button class="print-button" onclick="printPage();">Print</button>
    <button class="back-button" onclick="window.history.back();">Back</button>
</div>
</body>
</html>
