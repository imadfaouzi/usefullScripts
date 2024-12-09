from flask import Flask, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/deploy/<folder_name>', methods=['GET'])
def deploy(folder_name):
    # Path to the folder where the deploy.sh script is located
    folder_path = f"/app/chatbot/{folder_name}"

    # Check if the folder exists
    if not os.path.isdir(folder_path):
        return jsonify({"error": "Folder not found"}), 404

    # Path to the deploy.sh script
    deploy_script = os.path.join(folder_path, "deploy.sh")

    # Check if the deploy.sh script exists
    if not os.path.isfile(deploy_script):
        return jsonify({"error": "Deploy script not found"}), 404

    try:
        # Make the script executable (if not already)
        subprocess.run(["chmod", "+x", deploy_script], check=True)

        # Execute the deploy.sh script
        result = subprocess.run(
            [deploy_script],
            cwd=folder_path,  # Set the working directory to the folder path
            check=True,
            capture_output=True,
            text=True
        )

        # Return the output of the deployment process
        return jsonify({"message": "Deployment started", "output": result.stdout}), 200

    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Deployment failed: {e.stderr}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6161)
