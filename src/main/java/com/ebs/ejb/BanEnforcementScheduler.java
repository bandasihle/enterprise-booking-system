package com.ebs.ejb;

import com.ebs.entity.User;
import jakarta.ejb.Schedule;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * EJB Timer - runs hourly to lift expired bans.
 * Admin sets a 24-hour ban; this scheduler automatically lifts it.
 */
@Singleton
@Startup
public class BanEnforcementScheduler {

    @PersistenceContext(unitName = "ebs-PU")
    private EntityManager em;

    @Schedule(minute = "0", hour = "*", persistent = false)
    public void liftExpiredBans() {
        List<User> bannedUsers = em.createQuery(
            "SELECT u FROM User u WHERE u.banned = true AND u.banExpiry <= :now",
            User.class)
            .setParameter("now", LocalDateTime.now())
            .getResultList();

        for (User user : bannedUsers) {
            user.setBanned(false);
            user.setBanExpiry(null);
            user.setCancellationCount(0);
            System.out.println("[BanScheduler] Ban lifted for: " + user.getEmail());
        }
    }
}
