package main

import (
	"fmt"
	"os/exec"
	"strings"
)

type Conan struct {
	ProjectId string
	Region    string
	Zones     []string
}

func main() {
	c := Conan{ProjectId: "bamboo-depth-206411", Region: "europe-west1"}
	fmt.Println(c.GetOutput("gcloud", "projects", "list"))
	zonesRaw, err := c.GetOutput("gcloud", "compute", "zones", "list", fmt.Sprintf("--filter=%s", c.Region))
	if err != nil {
		panic(err)
	}
	c.Zones = c.convertToArray(zonesRaw, "NAME", 0)

	if c.IsApiEnabled("container.googleapis.com") {
		for _, z := range c.Zones {
			outputRaw, err := c.GetOutput("gcloud", "container", "clusters", "list", fmt.Sprintf("--filter=\"zone:(%s)\"", z))
			if err != nil {
				panic(err)
			}

			if outputRaw != "" {
				fmt.Println(outputRaw)
				////echo "deleting ${c}..."
				//	//gcloud container clusters delete --zone=$zone --quiet ${c}
				//
			}

		}
	}

}

func (c *Conan) IsApiEnabled(api string) bool {
	apiRaw, err := c.GetOutput("gcloud", "--project", c.ProjectId, "services", "list", "--enabled", fmt.Sprintf("--filter=%s", api))
	if err != nil {
		panic(err)
	}

	return strings.Contains(apiRaw, api)
}

func (c *Conan) RunSlient(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	err := cmd.Run()
	if err != nil {
		return err
	}
	return nil
}

func (c *Conan) GetOutput(name string, args ...string) (string, error) {
	out, err := exec.Command(name, args...).Output()
	if err != nil {
		return "", err
	}
	return string(out), nil
}

func (c *Conan) convertToArray(input string, header string, column int) []string {
	lines := strings.Split(string(input), "\n")
	var existingProjects []string
	for _, l := range lines {
		if strings.Contains(l, header) {
			continue
		}
		fields := strings.Split(l, " ")
		existingProjects = append(existingProjects, fields[column])
	}
	return existingProjects
}
