import React, {  useState,useEffect } from 'react'
import Artistlist from "./Artistlist"
import "./Artists.css"
import {Link} from "react-router-dom"
import axios from 'axios'

function Artists() {

  const [artist, setArtist] = useState([])
  
  useEffect(() => {
    const fetchData = async () => {
      const result = await axios(
        "https://g17.labagh.pl/api/artists?limit=1000&offset=0",
      );
 
      setArtist(result.data);
      
    };
 
    fetchData();
  },[]);


    return (
        <div className="artists">
        <div className="artists__info">
         
          <div className="artists__infoText">
            <strong>Artists</strong>
            <h2>Browse your artist</h2>
            <p></p>
          </div>
        </div>
  
        <div className="artists__songs">
          <div className="artists__icons">
           {
            artist.map((artist, i) =>
                <Link  key ={i} to = {"/albums/"+ artist.name+"/"+artist.id} style={{ textDecoration: 'none' }}><Artistlist key = {i} name = {artist.name}  img_src = {"https://g17.labagh.pl/media/"+artist.media}/></Link>      
            )
          }
        </div>
        </div>
      </div>
    );
  }

export default Artists
