package jd.eco.backend;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonUnwrapped;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.vladmihalcea.hibernate.type.json.JsonType;
import org.hibernate.annotations.Type;
import org.hibernate.annotations.TypeDef;

import javax.persistence.*;
import java.util.Date;
import java.util.HashMap;
import java.util.UUID;

@Entity(name = "mylogs")
@TypeDef(name = "json", typeClass = JsonType.class)
@JsonSerialize(using = LogEntrySerializer.class)
public class LogEntry {
    @Id
    @GeneratedValue(generator = "UUID")
    private UUID id;
    private Date createdAt;
    private String level;
    @JsonAnySetter
    @Type(type = "json")
    @Column(columnDefinition = "json")
    private HashMap<String, JsonNode> payload;

    public LogEntry() {
        this.payload = new HashMap<>();
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public HashMap<String, JsonNode> getPayload() {
        return payload;
    }

    public void setPayload(HashMap<String, JsonNode> payload) {
        this.payload = payload;
    }

    @Override
    public String toString() {
        return "LogEntry{" +
                "id=" + id +
                ", createdAt=" + createdAt +
                ", level='" + level + '\'' +
                ", payload=" + payload +
                '}';
    }
}
