import React from 'react'
import "./Artistlist.css"
function Songlist({  name, img_src }) {
    return (
        <div className="artistsRow" >
        <img className="artistsRow__album" src= {img_src} alt="" />
        <div className="artistsRow__info">
          <h1>{name}</h1>
        </div>
      </div>
    );
  }
  

export default Songlist
