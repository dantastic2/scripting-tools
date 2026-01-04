import json
import sys
import re
import os
import requests
from pathlib import Path
from dataclasses import dataclass
from urllib.request import urlretrieve
import urllib.error
from tvdb_v4_official import TVDB
from term_image.image import from_url



	   
#Configuration: 
fileExtensions = ['.mkv', '.mp4', '.avi','.iso','.img','.mpg','.m4v']
filterFiles = ['_unpack','sample','._'] #don't process files with this in filename
filterWords = ['REPACK','repack','AV1'] #remove these strings from output filename --- NOT YET IMPLEMENTED
resolutions = "(1080p|1080i|2160p|720p|SD)"
exceptionStrings = ['A.P.','Jr.','C.O.P.S.','Mr.','Dr.','Sr.','R.L.','Tosh.0','O.C.']
charReplaceMap = {".": " ", "_": " ", "[": "(", "]": ")", "@": "a"}

escapeChars = str.maketrans({"!": "\\!",":": ""})
escapeCharsFilename = str.maketrans({"!": "\\!"})
episodeKeyRegex = r"([Ss][0-9]{1,2}\s*[Ee][0-9]{2,3})" #checks for S##E## or s##e## in filename

#source mapping, put default value first
remux = 'Remux REMUX remux re-mux Re-mux'.split()
memux = 'Memux MEMUX memux Me-mux me-mux'.split()
web = ['WEB']
bluray=['BluRay','bluray','Bluray','Blu-ray','Blu-Ray',' BLURAY','BLU-RAY','blu-ray','BrRip','BRRIP','brrip']
sourceMap = (remux,memux,web,bluray)

dv = 'DV DoVi DolbyVision'.split()
dv2 = ['DV ','Dovi','DolbyVision']

#encode type mapping, put default first
x265 = 'x265 X265 H265 h265'.split()
x264 = 'x264 X264 H264 h264'.split()
encodeTypeMap = (x265,x264)

#TVDB API URL Building 
tvdbAPIUrl = "https://api.thetvdb.com/"
tvdbAPIKey = "2c891cf8-0b3a-4b0d-9b7f-e13d4485b2e3"
if len(sys.argv) > 1:
   seasonOrder = sys.argv[1] # aired, alternate, dvd
   episodeNumberField = sys.argv[1] # aired or dvd
else:
   seasonOrder = "aired" # aired, alternate, dvd
   episodeNumberField = "aired" # aired or dvd


tvdbSeriesIds = []
tvdbFeeds = []


def splitArray(inputArray,separator):
   outputArray = []
   if inputArray is not None:
      for x in inputArray:
         outputArray = outputArray + re.split(f'({re.escape(separator)})', x)
   return outputArray


def replaceExcept(inputString):
   outputArray = [inputString]
   for originalChar, replacementChar in charReplaceMap.items():
      for x in exceptionStrings:
           outputArray = splitArray(outputArray,x)
      for i in range(len(outputArray)):
         if outputArray[i] not in exceptionStrings:
            outputArray[i] = outputArray[i].replace(originalChar,replacementChar)
      # Join back into a string
      result_str = "".join(outputArray)
   return(result_str)


def getJsonObjectByFieldname(json_data, fieldname, fieldvalue):
      try:
         for obj in json_data:
            if fieldname in obj and obj[fieldname] == fieldvalue:
               return obj
      except json.JSONDecodeError:
         return None
         

def getJsonObjectFieldnamesByKeyFieldName(json_data, keyFieldName, fieldValue, fieldName):
      appendedFieldnames = []
      try:
         for obj in json_data:
            if keyFieldName in obj and obj[keyFieldName] == fieldValue:
               appendedFieldnames.append(obj[fieldName])
         return ", ".join(appendedFieldnames)
      except json.JSONDecodeError:
         return None


def getEpisodeTitle(episode):
   tvdbSeriesId = episode.tvdbSeriesId
   #pageNumber = str(int((int(episode.episodeNumber)-1) / 100)+1)
   url = tvdbAPIUrl + "series/" + tvdbSeriesId + "/episodes/query?" + seasonOrder + "Season=" + episode.season + "&apikey=" + tvdbAPIKey + "&page="
   #print(url)
   urlKey = tvdbSeriesId + seasonOrder + episode.season
   found = "false"
   all_data = []

   for tvdbFeedDict in tvdbFeeds: 
      try:
         if tvdbFeedDict[urlKey]:
            all_data = tvdbFeedDict[urlKey]
            found = "true"
            break
      except KeyError:
         pass
   if found == "false":
      try:
         response = requests.get(url)
         data = response.json()
         total_pages = data.get("links", {}).get("last")
         for pageNum in range(1, total_pages+1):
             apiUrl = url + str(pageNum)
             response = requests.get(apiUrl)
             current_page_data = response.json()
             all_data.extend(current_page_data.get("data", []))
         dictionary = {urlKey: all_data}
         tvdbFeeds.append(dictionary)        
         """
         path, _ = urlretrieve(url,"../../.cache/." + urlKey)
         with open(path, 'r') as f:
            data = json.load(f)
            dictionary = {urlKey: data}
            tvdbFeeds.append(dictionary)
         """
      except urllib.error.URLError:
         print ("URL Error")
   #result = getJsonObjectByFieldname((data['data']), seasonOrder + "EpisodeNumber", int(episode.episodeNumber))
   episodeTitle = getJsonObjectFieldnamesByKeyFieldName(all_data,  episodeNumberField + "EpisodeNumber", int(episode.episodeNumber),"episodeName")
   if episodeTitle is not None:
      #episodeTitle = " " + result['episodeName'].translate(escapeChars) #remove chars not allowed in filename
      return " " + episodeTitle.translate(escapeChars)
   else:
      return ""
   return ""



@dataclass
class Series():
    seriesName: str
    seriesId: str = ""
    seriesReleaseYear: str = ""
    seriesDirectory: str = ""
    def __post_init__(self):
      showTitleKey = self.seriesName.lower().replace(" ","")
      for seriesIdDict in tvdbSeriesIds: 
         try:
            if seriesIdDict["key"] == showTitleKey:
               self.seriesId = seriesIdDict["seriesId"]
               self.seriesName = seriesIdDict["name"]
               self.seriesReleaseYear = seriesIdDict["year"]
               self.seriesDirectory = seriesIdDict["directory"]
         except KeyError:
            pass 
      if self.seriesId == "":
         try:
            tvdb = TVDB(tvdbAPIKey)
            #print (self.seriesName)
            results = tvdb.search(query=self.seriesName, type="series")
            if not results:
               #try removing year from series name to see if that gets a result
               year = re.search(r"((19|20)[0-9]{2})", self.seriesName).group(0)
               print("ERROR:  No results")	
               results = tvdb.search(query=self.seriesName.replace(year,""), type="series")

            for result in results:
               imageUrl = result['image_url']
               image = from_url(imageUrl)
               image.height = 15
               #image.draw()
               print(image)
               isCorrect = input("Is this the correct series [y/n] - " + result['name'] + " (" + result['year'] + ") ?   ")
               if isCorrect == 'y':
                  self.seriesId = result['tvdb_id']
                  self.seriesReleaseYear = result['year']
                  self.seriesName = result['name']
                  self.seriesDirectory = self.seriesName
                  if self.seriesReleaseYear not in self.seriesName:
                     self.seriesDirectory += " (" + self.seriesReleaseYear + ")"
                  print(self.seriesName + " -> " + self.seriesDirectory)
                  break
            dictionary = {"key": showTitleKey, "seriesId": self.seriesId, "name": self.seriesName, "year": self.seriesReleaseYear, "directory": self.seriesDirectory}
            tvdbSeriesIds.append(dictionary)
         except Exception as e:
            print(f"An error occurred: {e}")    


@dataclass
class Episode():
    filename: str
    directory: str
    sourceEpisodeKey: str = ""
    outputEpisodeKey: str = ""
    newFilename: str = ""
    resolution: str = ""
    tvdbSeriesName: str = ""
    tvdbSeriesId: str = ""
    showTitle: str = ""
    season: str = ""
    episodeNumber: str = ""
    seasonDirectory: str = ""
    fileExtension: str = ""
    episodeTitle: str = "" 
    def __post_init__(self):
       if re.search(episodeKeyRegex, self.filename):
          self.sourceEpisodeKey = re.search(episodeKeyRegex, self.filename).group(1)
          self.outputEpisodeKey = self.sourceEpisodeKey.replace(" ","").upper()
       elif re.search(r"[Ss]eason[' ',.]\d{1,2}", dirpath):
          #determine if we already have an episode key in the filename.  
          self.sourceEpisodeKey = re.search(r"\d{3,4}", self.filename).group(0)
          self.outputEpisodeKey =  "S" + self.sourceEpisodeKey[:-2].zfill(2) + "E" + self.sourceEpisodeKey[-2:]
       self.season = self.outputEpisodeKey[:3][-2:]
       self.episodeNumber = self.outputEpisodeKey.partition("E")[2]
       self.filename = self.filename.translate(escapeCharsFilename)
       self.directory = self.directory.translate(escapeChars)
       self.fileExtension = self.filename[-4:]
       filename = self.filename.replace(self.fileExtension,"")       
       filename  = replaceExcept(filename)

       self.showTitle, _, self.episodeTitle = filename.partition(self.sourceEpisodeKey)
       self.showTitle = self.showTitle.split('(', 1)[0]
       tvdbSeries  = Series(self.showTitle)
       self.tvdbSeriesId = tvdbSeries.seriesId
       self.tvdbSeriesName = tvdbSeries.seriesName.translate(escapeChars)
       self.seriesDirectory = tvdbSeries.seriesDirectory.translate(escapeChars)  + "/"
       self.seasonDirectory = self.seriesDirectory + self.tvdbSeriesName + " - Season " + self.season + "/" 
       try:
          self.resolution = " " + re.search(resolutions,filename).group(1)
          self.episodeTitle, _, _ = self.episodeTitle.partition(self.resolution)
       except AttributeError:
          self.resolution = ""   
       
       self.episodeTitle = getEpisodeTitle(self).replace("/","-").replace(":","") #remove chars not allowed in filename
       
       #create newFilename
       self.newFilename = self.seasonDirectory + self.tvdbSeriesName + " - " + self.outputEpisodeKey + self.episodeTitle + self.fileExtension


@dataclass
class Movie():
    filename: str
    directory: str
    title: str = ""
    newFilename: str = ""
    encodeType: str = ""
    dolbyVision: str = ""
    releaseYear: str = ""
    resolution: str = ""
    source: str = ""
    def __post_init__(self):
       self.filename = self.filename.translate(escapeChars)
       self.fileExtension = self.filename[-4:]
       if self.directory != "":
          filename = self.directory
       else:
          filename = self.filename.replace(self.fileExtension,"")
       try:
          self.resolution = " " + re.search(resolutions, filename).group(1)
       except AttributeError:
          self.resolution = ""           
       filename  = replaceExcept(filename)
       #filename = filename.translate(charReplaceMap)
       self.seriesDirectory = ""
       try: 
          #releaseYear = re.search(r"\(*((19|20)[0-9]{2}\)*)", filename).group(1)
          releaseYear = re.search(r"((19|20)[0-9]{2})", filename).group(1)
          self.title, _, _ = filename.partition(releaseYear)
          self.title = self.title.replace('(','').replace(')','')
          releaseYear = "(" + releaseYear + ")"
       except AttributeError:
          self.title = filename[:-1] + " - " + self.filename[:-4]
          releaseYear = ""
       self.releaseYear = releaseYear
       for encodeTypes in encodeTypeMap: 
          if any(x in filename for x in encodeTypes):
             self.encodeType = " " + encodeTypes[0]
             break
       for sources in sourceMap: 
          if any(x in filename for x in sources):
             self.source = " " + sources[0]
             break
       if any(x in filename.replace('DVD','') for x in dv):
          self.dolbyVision = " " + dv[0]
       #create newFilename
       self.newFilename = self.title + self.releaseYear + self.resolution + self.source + self.encodeType + self.dolbyVision + self.fileExtension


videos = []
dirPaths = []

#walk through all directories and files in current path
for dirpath, dirnames, filenames in os.walk(Path.cwd()):
    dirPaths.append(dirpath.partition(Path.cwd().name + "/")[2] + "/")
    for filename in filenames:
        #allow only listed file extensions and filter files with banned strings
        if any(x in filename[-4:].lower() for x in fileExtensions) and not any(x in filename for x in filterFiles):        
           currentDir = Path.cwd()
           _, _, directory = dirpath.partition(Path.cwd().name + "/")
           if directory != "":
              directory=directory+"/"
           #if we find evidence that this is a TV episode: 
           if re.search(episodeKeyRegex, filename) or re.search(r"[Ss]eason[' ',.]\d{1,2}", dirpath):
              episode =  Episode(filename,directory)
              videos.append(episode)
           #if we find evidence this is a music video
           elif "Music Videos" in dirpath:
              musicVideos = "true" #TO ADD 
           #otherwise, assume it's a movie.  
           else:
              movie = Movie(filename, directory)
              newFilename = movie.newFilename
              videos.append(movie)          

print ("\n\n\n\n")

#create tv series & season directories if they don't already exist             
for newDir in set([vid.seriesDirectory for vid in videos if vid.__class__.__name__ == 'Episode' and vid.directory != vid.seriesDirectory and vid.seriesDirectory not in dirPaths and vid.seriesDirectory != '/']):
   print ("mkdir -p \"" + newDir + "\"")
for newDir in set([vid.seasonDirectory for vid in videos if vid.__class__.__name__ == 'Episode' and vid.directory != vid.seasonDirectory and vid.seasonDirectory not in dirPaths and vid.seriesDirectory != '/']):
   print ("mkdir -p \"" + newDir + "\"")

#create file mover/rename commands
for video in sorted(videos, key=lambda x: x.newFilename):
   if video.directory + video.filename != video.newFilename:
      print ("mv \"" + video.directory + video.filename + "\" \"" + video.newFilename + "\"")

#remove old directories no longer used      
for newDir in set([vid.directory.split('/', 1)[0] for vid in videos if vid.directory != "" and vid.directory.split('/', 1)[0]+ "/" != vid.seriesDirectory ] ):
  print ("mv \"" + newDir.translate(escapeCharsFilename) + "/\" ../_cleanup/")
