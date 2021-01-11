import React, { useContext,useEffect } from 'react'

import Artistlist from "./Artistlist"
import "./Albums.css"
import { Link} from "react-router-dom"
import playerContext from '../context/PlayerContext'
import axios from 'axios';


function Album() {
    
    const { albums, setAlbum,SetCurrent, setPlayingFalse} = useContext(playerContext)

  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/albums?limit=1000&offset=0",
      );
 
      setAlbum(result.data);
      
    };
 
    fetchData();
  },[]);

  
  
      
        
    return (

        <div className="album">
        <div className="album__info">
         
          <div className="album__infoText">
            <strong>Albums</strong>
            <h2>Browse by album</h2>
            <p></p>
          </div>
        </div>
  
        <div className="album__songs">
          <div className="album__icons">
           
            { 
          albums.map((album, i)=>
                <Link onClick={() => { SetCurrent(0); setPlayingFalse()}} key = {i} to = {"/albums/"+album.name+"/"+ album.id+ "/songs"} style={{ textDecoration: 'none' }}><Artistlist key = {i} name = {album.name}  img_src = {"https://g17.labagh.pl/media/"+album.media}/></Link> 
            
           )}
        </div>
        </div>
      </div>
    );
  }
    
export default Album
