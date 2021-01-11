import React from 'react'
import "./Songlist.css"
function Songlist({ title , artist, genre, img_src }) {
    return (
        <div className="songRow" >
        <img className="songRow__album" src= {img_src} alt="" />
        <div className="songRow__info">
          <h1>{title}</h1>
          <p>
            {artist} {"  -  "}{genre}
          </p>
        </div>
      </div>
    );
  }
  

export default Songlist
