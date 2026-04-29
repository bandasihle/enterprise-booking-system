
import com.ebs.config.DatabaseConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/*
 * GET /api/users
 * Returns all users including suspension status.
 * Auto-lifts suspension if suspended_until has passed.
 */
@WebServlet("/api/users")
public class GetUsersServlet extends HttpServlet {

    /**
     *
     * @param request
     * @param response
     * @throws IOException
     */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setContentType("application/json");

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Auto-lift expired suspensions first
            conn.prepareStatement(
                "UPDATE users SET is_suspended = false, suspended_until = NULL " +
                "WHERE is_suspended = true AND suspended_until < NOW()"
            ).executeUpdate();

            // Fetch all users
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, full_name, email, role, is_banned, " +
                "is_suspended, suspended_until FROM users ORDER BY id ASC"
            );

            ResultSet rs = ps.executeQuery();
            StringBuilder users = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) users.append(",");
                first = false;

                String suspendedUntil = rs.getString("suspended_until");

                users.append("{")
                     .append("\"id\":").append(rs.getInt("id")).append(",")
                     .append("\"full_name\":\"").append(safe(rs.getString("full_name"))).append("\",")
                     .append("\"email\":\"").append(safe(rs.getString("email"))).append("\",")
                     .append("\"role\":\"").append(safe(rs.getString("role"))).append("\",")
                     .append("\"is_banned\":").append(rs.getBoolean("is_banned")).append(",")
                     .append("\"is_suspended\":").append(rs.getBoolean("is_suspended")).append(",")
                     .append("\"suspended_until\":").append(
                         suspendedUntil != null
                             ? "\"" + suspendedUntil + "\""
                             : "null"
                     )
                     .append("}");
            }

            users.append("]");

            response.getWriter().write("{\"users\":" + users + "}");

        } catch (Exception e) {
            System.out.println("❌ GetUsersServlet error: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"users\":[]}");
        }
    }

    private String safe(String s) {
        return s == null ? "" : s.replace("\"", "'");
    }

    
    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}