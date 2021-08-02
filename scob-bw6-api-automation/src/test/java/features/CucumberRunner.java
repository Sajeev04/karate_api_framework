package features;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

public class CucumberRunner {
	@Test
	public void testParallel() {
		String karateOutputPath = "target/cucumber-html-reports";
		Results stats = Runner.parallel(getClass(), 1, karateOutputPath);
		generateReport(karateOutputPath);
		assertTrue("there are scenario failures", stats.getFailCount() == 0);
	}

	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static void generateReport(String karateOutputPath) {
		Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] { "json" }, true);
		List<String> jsonPaths = new ArrayList(jsonFiles.size());
		jsonFiles.removeIf(file -> file.length() == 0);
		jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
		Configuration config = new Configuration(new File("target"), "End To End SBCOB Api Test Cases Runner");
		ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
		reportBuilder.generateReports();
	}

}
