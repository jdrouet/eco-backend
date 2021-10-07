package jd.eco.backend;

import org.springframework.data.repository.CrudRepository;

import java.util.UUID;

public interface LogEntryRepository extends CrudRepository<LogEntry, UUID> {
}
