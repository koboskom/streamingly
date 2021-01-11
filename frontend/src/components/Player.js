import React,   { useState, useEffect, useRef, useContext } from "react";
import PlayCircleOutlineIcon from "@material-ui/icons/PlayCircleOutline";
import SkipPreviousIcon from "@material-ui/icons/SkipPrevious";
import SkipNextIcon from "@material-ui/icons/SkipNext";
import ShuffleIcon from "@material-ui/icons/Shuffle";
import PauseCircleOutlineIcon from "@material-ui/icons/PauseCircleOutline";
import "./Player.css";
import { Grid } from "@material-ui/core";
import PlayerContext from '../context/PlayerContext'
import axios from 'axios'

function Player(props) {
  const {
    currentSong,
    songs,
    albums,
    nextSong,
    prevSong,
    random,
    playing,
    toggleRandom,
    togglePlaying,
    handleEnd,
    setAlbum
    

  } = useContext(PlayerContext)

  const audio = useRef('audio_tag');

  // self State
  const [statevolum] = useState(0.3)
  const [dur, setDur] = useState(0)
  const [currentTime, setCurrentTime] = useState(0) 

  const fmtMSS = (s) => { return (s - (s %= 60)) / 60 + (9 < s ? ':' : ':0') + ~~(s) }

  const toggleAudio = () => audio.current.paused ? audio.current.play() : audio.current.pause();


  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/albums?limit=1000&offset=0",
      );
 
      setAlbum(result.data);
      
    };
 
    fetchData();
  },[]);

  const handleProgress = (e) => {
    let compute = (e.target.value * dur) / 100;
    setCurrentTime(compute);
    audio.current.currentTime = compute
  }

  useEffect(() => {
    audio.current.volume = statevolum;
    if (playing) { toggleAudio() }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentSong])


  // eslint-disable-next-line no-lone-blocks
  {
    if (typeof songs[currentSong].artists !== 'undefined' && typeof songs[currentSong].genres !== 'undefined' ){ 
      const newArtist = songs[currentSong].artists.toString().replace(/[0-9]/g, '').replace(',',' ');
      const newGenre = songs[currentSong].genres.toString().replace(/[0-9]/g, '').replace(',',' ').replace(',,',' ').replace(',,',' ');

   

    return (

  

    <div className="footer">
       
    <audio 
    onTimeUpdate={(e) => setCurrentTime(e.target.currentTime)}
    onCanPlay={(e) => setDur(e.target.duration)}
    onEnded={handleEnd}
    ref={audio}
    type="audio/mpeg"
    preload='true'
    src={"https://g17.labagh.pl/media/"+songs[currentSong].media}
    />
       
      <div className="footer__left">
       { 
      albums.filter(
        (album) => album.id === songs[currentSong].album_id
        ).map((album)=>
      <img
          key = {album.id}
          src = {"https://g17.labagh.pl/media/"+album.media } alt =""
          className="footer__albumLogo"         
        />
        )}
    <div className="footer__songInfo">
            <h4 >{songs[currentSong].title}</h4>
            <p>{newArtist}{" - "}{newGenre}</p>
          </div>
    </div>

      <div className="footer__center">
      <ShuffleIcon onClick={toggleRandom} className={"random " + (random ? 'ractive' : '')} />
        <SkipPreviousIcon onClick={prevSong} className="footer__icon" />      
        {playing ? (
          <PauseCircleOutlineIcon
          onClick={() => { togglePlaying(); toggleAudio(); }}
            fontSize="large"
            className="footer__icon__play"
          />
        ) : (
          <PlayCircleOutlineIcon
          onClick={() => { togglePlaying(); toggleAudio(); }}
            fontSize="large"
            className="footer__icon__play"
          />
        )}
 
        <SkipNextIcon  onClick={nextSong} className="footer__icon" />
        
      </div>
      <div className="footer__right">
      <Grid container spacing={2}>
          
          <Grid item>
            
          </Grid>
          <Grid item xs>
          <div className="progressb">
        <span className="currentT">{fmtMSS(currentTime)}</span>
        <input
          onChange={handleProgress}
          value={dur ? (currentTime * 100) / dur : 0}
          type="range" name="progresBar" id="prgbar" />
        <span className="totalT">{fmtMSS(dur)}</span>
      </div>
          </Grid>
        </Grid>
      </div>
    </div>
    )
}
} 
}
export default Player
