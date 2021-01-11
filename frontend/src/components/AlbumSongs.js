import React, { useContext,useEffect } from 'react'
import {useParams } from "react-router-dom"
import Songlist from "./Songlist"
import playerContext from '../context/PlayerContext'
import axios from 'axios'

function AlbumSongs() {
    const {name, id} = useParams();
    const { SetCurrent, currentSong, songs,albums,setSongs, setAlbum } = useContext(playerContext)
    // const [song, setSong] = useState([])
   
    useEffect(() => {
      const fetchData = async () => {
        const result = await axios(
          "https://g17.labagh.pl/api/albums?limit=1000&offset=0",
        );
   
        setAlbum(result.data);
        
      };
   
      fetchData();
    },[]);
    useEffect(() => {
      const fetchData = async () => {
        const result = await axios(
          "https://g17.labagh.pl/api/albums/"+id+"/songs?limit=1000&offset=0",
        );
   
        setSongs(result.data);
        
      };
   
      fetchData();
    },[]);
    
    
     
    
    

    return (
        <div className="body">
        <div className="body__info">
         
          <div className="body__infoText">
            <h2>Album: {name}</h2>
            <p></p>
          </div>
        </div>
  
        <div className="body__songs">
          <div className="body__icons">
          </div>

        { 
          songs.map((song, i)=>{
            if (typeof song.artists !== 'undefined'){ 
              const albumtIneed = albums.find(
                (album) => album.id === song.album_id

                )
             if (typeof song.artists !== 'undefined'){ 
                const newArtist = song.artists.toString().replace(/[0-9]/g, '').replace(',',' ');
                const newGenre = song.genres.toString().replace(/[0-9]/g, '').replace(',',' ').replace(',,',' ').replace(',,',' ');
             
              if (typeof albumtIneed !== 'undefined'){
            return(
              
                <div className={'songContainer ' + (currentSong === i ? 'selected1' : '')} key={song.id} onClick={() => { SetCurrent(i); }}>
                        
                        <Songlist key={i} title ={song.title} artist = {newArtist} genre = {newGenre} img_src = {"https://g17.labagh.pl/media/"+albumtIneed.media}/>
                      </div>
            );
           } }}})
          }
        </div>
      </div>
    );
  }


export default AlbumSongs
