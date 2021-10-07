package jd.eco.backend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
public class BackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

	@Autowired
	private LogEntryRepository logEntryRepository;

	@GetMapping(path = "/status")
	public void status() {
		// Nothing to do
	}

	@GetMapping(path = "/search")
	public Iterable<LogEntry> search(@RequestParam(value = "count", defaultValue = "100") int count, @RequestParam(value = "offset", defaultValue = "0") int offset) {
		return this.logEntryRepository.findAll();
	}

	@PostMapping(path = "/publish", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
	public void publish(@RequestBody Iterable<LogEntry> payloads) {
		this.logEntryRepository.saveAll(payloads);
	}
}
