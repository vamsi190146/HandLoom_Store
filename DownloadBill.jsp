<%@ page language="java" contentType="application/pdf" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, org.apache.pdfbox.pdmodel.*, org.apache.pdfbox.pdmodel.font.*, org.apache.pdfbox.pdmodel.graphics.image.*" %>
<%@ page import="jakarta.servlet.ServletException, jakarta.servlet.http.HttpServletResponse, jakarta.servlet.http.HttpSession" %>

<%
    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "attachment; filename=BillReceipt.pdf");

    HttpSession httpSession = request.getSession();
    String gid = (String) httpSession.getAttribute("currentuser");
    if (gid == null || gid.isEmpty()) {
        response.sendRedirect("Login.jsp"); // Redirect if user is not logged in
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/your_database_name", "root", "Tvamsi152@"); // Replace 'your_database_name' with the actual database name

        String query = "SELECT * FROM orders WHERE uid = ?";
        ps = conn.prepareStatement(query);
        ps.setString(1, gid);
        rs = ps.executeQuery();

        PDDocument document = new PDDocument();
        PDPage pdfPage = new PDPage();
        document.addPage(pdfPage);

        PDPageContentStream contentStream = new PDPageContentStream(document, pdfPage);
        contentStream.setFont(PDType1Font.HELVETICA_BOLD, 16);
        contentStream.beginText();
        contentStream.newLineAtOffset(50, 700);
        contentStream.showText("Order Receipt for User ID: " + gid);
        contentStream.newLine();
        contentStream.newLine();

        contentStream.setFont(PDType1Font.HELVETICA, 12);

        contentStream.showText("Order ID\tProduct ID\tPrice\tQuantity\tTotal");
        contentStream.newLine();
        contentStream.showText("----------------------------------------------");
        contentStream.newLine();

        double totalAmount = 0.0;

        while (rs.next()) {
            String orderId = rs.getString("oid");
            String productId = rs.getString("pid");
            int price = rs.getInt("price");
            int quantity = rs.getInt("quantity");
            int total = price * quantity;

            contentStream.showText(orderId + "\t" + productId + "\t" + price + "\t" + quantity + "\t" + total);
            contentStream.newLine();

            totalAmount += total;
        }

        contentStream.newLine();
        contentStream.showText("Total Amount: " + totalAmount);
        contentStream.endText();
        contentStream.close();

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        document.save(byteArrayOutputStream);
        document.close();

        response.setContentLength(byteArrayOutputStream.size());
        OutputStream outputStream = response.getOutputStream();
        byteArrayOutputStream.writeTo(outputStream);
        outputStream.flush();
        outputStream.close();

    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
