<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- ABOUT THE PROJECT -->
## About The Project

Bash File timestamp update script

Motivation: 

In large scale data processing, sometimes files get "stuck" and the file timestamp needed to be updated to get noticed as a new file and get processed.
While system error or maintenance, many files could wait for processing, the files should be not updated.
If stuck files are updated endlessly, an system error could be unnoticed.

Remarks: 

Run the script with sufficent permissions to update the files

Each file is updated only once. Already updated file names are read from the logfile. Creating new logfiles could result repeated file update.

The script reads the modified timestamp (mtime) and modifies all 3 timestamps: access timestamp (atime), modified timestamp (mtime), change timestamp (ctime)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/Adams77777/file_timestamp_update
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Update files in a folder with extension .dat and .txt, if the files are older then 30 minutes, and found not more then 15 files to update
```
./file_timestamp_update.sh /path/to/folder 30 ".dat,.txt" 15 /path/to/logfile.log
```

Update files in a folder, if the files are older then 15 minutes, and found not more then 50 files to update
```
./file_timestamp_update.sh /path/to/folder 15 "*" 50 /path/to/logfile.log
```

Update files in a folder, if the files are older then 15 minutes
```
./file_timestamp_update.sh /path/to/folder 15 "*" 0 /path/to/logfile.log
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Adam Sebestyen - sebestyen.adam.attila@gmail.com

Project Link: [https://github.com/Adams77777/file_timestamp_update](https://github.com/Adams77777/file_timestamp_update)

<p align="right">(<a href="#readme-top">back to top</a>)</p>
