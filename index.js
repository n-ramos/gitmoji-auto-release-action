const core = require('@actions/core');
const github = require('@actions/github');
const { execSync } = require('child_process');

(async () => {
    try {
        const branch = core.getInput('branch');

        // Fetch all tags
        execSync('git fetch --tags');

        // Get the latest tag
        const latestTag = execSync('git describe --tags `git rev-list --tags --max-count=1`').toString().trim();

        // Get commits since the latest tag
        const commits = execSync(`git log ${latestTag}..HEAD --pretty=format:"%s"`).toString().trim().split('\n');

        let patch = 0;
        let minor = 0;
        let major = 0;

        let releaseBody = '';
        commits.forEach(commit => {
            if (commit.includes(':bug:') || commit.includes(':lock:') || commit.includes(':adhesive_bandage:')) {
                patch++;
            } else if (commit.includes(':sparkles:') || commit.includes(':rocket:') || commit.includes(':zap:')) {
                minor++;
            } else if (commit.includes(':boom:') || commit.includes(':firecracker:')) {
                major++;
            }
            releaseBody += `- ${commit}\n`;
        });

        const [latestMajor, latestMinor, latestPatch] = latestTag.replace('v', '').split('.').map(Number);

        let newTag;
        if (major > 0) {
            newTag = `v${latestMajor + 1}.0.0`;
        } else if (minor > 0) {
            newTag = `v${latestMajor}.${latestMinor + 1}.0`;
        } else {
            newTag = `v${latestMajor}.${latestMinor}.${latestPatch + 1}`;
        }

        const releaseName = `Release ${newTag}`;

        // Create the new tag
        execSync(`git tag ${newTag}`);
        execSync(`git push origin ${newTag}`);

        core.setOutput('tag', newTag);
        core.setOutput('release_name', releaseName);
        core.setOutput('release_body', releaseBody);
    } catch (error) {
        core.setFailed(error.message);
    }
})();
