package jd.eco.backend;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.Date;
import java.util.Map;

public class Event {
    private Date ts;
    private Map<String, String> tags;
    private Map<String, JsonNode> values;

    public Event() {
    }

    public Date getTs() {
        return ts;
    }

    public void setTs(Date ts) {
        this.ts = ts;
    }

    public Map<String, String> getTags() {
        return tags;
    }

    public void addTag(String key, String value) {
        this.tags.put(key, value);
    }

    public void setTags(Map<String, String> tags) {
        this.tags = tags;
    }

    public Map<String, JsonNode> getValues() {
        return values;
    }

    public void setValues(Map<String, JsonNode> values) {
        this.values = values;
    }
}
