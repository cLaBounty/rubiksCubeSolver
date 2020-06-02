class ThreeDimCube extends Cube {
  
  /*
  Phase 1: Align white center to top
  Phase 2: Align green center to front
  Phase 3: Solve all edge pieces
  Phase 4: Solve all corner pieces
  */
  private int solvePhase;
  private int edgeSwapCount;
  
  ThreeDimCube() {
    super();
    
    dim = 3;
    cellLength = CUBE_LENGTH / 3;
    cells = new Cell[27];
    turnOffset = 0;
    scrambleTurnNum = 30;
    
    turnXBases = new char[]{'L', 'M', 'R'};
    turnYBases = new char[]{'U', 'E', 'D'};
    turnZBases = new char[]{'B', 'S', 'F'};
    
    solvePhase = 1;
    edgeSwapCount = 0;
  }
  
  public void solve() {
    isSolving = true;
        
    // reset the solve sequence
    solveTurnSequence.removeAll(solveTurnSequence);
    turnCount = 0;
    solvePhase = 1;
    edgeSwapCount = 0;
  }
  
  protected void setNextTurns() {
    if (solvePhase == 1) {
      alignWhiteCenter();
      
      // next phase
      solvePhase++;
    }
    else if (solvePhase == 2) {
      alignGreenCenter();
      
      // next phase
      solvePhase++;
    }
    else if (solvePhase == 3) {
      if (!areEdgesSolved())
        solveEdge();
      else {
        // Parity Algorithm (only if an odd # of edges were moved)
        if (edgeSwapCount % 2 == 1)
          addParityAlgorithm();
        
        // next phase
        solvePhase++;
      }
    }
    else if (solvePhase == 4) {
      if (!isSolved())
        solveCorner();
      else
        isSolving = false;
    }
  }
  
  // align the white center cell
  private void alignWhiteCenter() {
    if (cells[10].currentY != 0) { // already solved
      if (cells[10].currentX == 1) {
        if (cells[10].currentZ == 0)
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        else if (cells[10].currentZ == 2)
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        else {
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        }
      }
      else if (cells[10].currentX == 0)
        solveTurnSequence.add(new TurnAnimation('S', 1)); // S
      else // currentX == 2
        solveTurnSequence.add(new TurnAnimation('S', -1)); // S'
    }
  }
  
  // align the green center cell
  private void alignGreenCenter() {
    if (cells[14].currentZ != 2) { // already solved
      if (cells[14].currentX == 0)
        solveTurnSequence.add(new TurnAnimation('E', -1)); // E
      else if (cells[14].currentX == 2)
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      else {
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
        solveTurnSequence.add(new TurnAnimation('E', 1)); // E'
      }
    }
  }
  
  private boolean areEdgesSolved() {
    // loop through all edge pieces to see if any are flipped or in the incorrect position
    for (Cell c : cells) {
      if (c.coloredFaces.size() == 2) {
        if (c.currentX != c.solvedX || c.currentY != c.solvedY || c.currentZ != c.solvedZ ||
            c.coloredFaces.get(0).dir.x != c.coloredFaces.get(0).initialDir.x ||
            c.coloredFaces.get(0).dir.y != c.coloredFaces.get(0).initialDir.y) {
              return false;
        }
      }
    }

    return true;
  }
  
  private void solveEdge() {
    // T Perm Algorithm
    final TurnAnimation[] T_PERM_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1), // R
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1) // F'
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 0; i < cells.length; i++) {
      if (cells[i].currentX == 2 && cells[i].currentY == 0 && cells[i].currentZ == 1) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the up and right face color of the buffer cell
    color bufferUpColor = #FFFFFF;
    color bufferRightColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == -1) // up face
         bufferUpColor = f.col;
      else if (f.dir.x == 1) // right face
         bufferRightColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = 1;
    int swapCellY = 1;
    int swapCellZ = 1;

    if (bufferUpColor == #FF8D1A || bufferRightColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferUpColor == #FF0000 || bufferRightColor == #FF0000)
      swapCellX = 2;
    
    if (bufferUpColor == #FFFFFF || bufferRightColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferRightColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferUpColor == #0000FF || bufferRightColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferRightColor == #00FF00)
      swapCellZ = 2;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferUpColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferUpColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferUpColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferUpColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferUpColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);

    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getEdgeSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // reversed setup moves to put back in it's original place
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--)
      reverseSetUpSequence.add(setUpSequence.get(i).invert());

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(T_PERM_ALG));
    solveTurnSequence.addAll(reverseSetUpSequence);
    
    // increment the edge swap counter
    edgeSwapCount++;
  }
  
  private void solveCorner() {
    // Modified Y Perm Algorithm
    final TurnAnimation[] MOD_Y_PERM_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1), // F'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1), // U'
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1) // R
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 0; i < cells.length; i++) {
      if (cells[i].currentX == 0 && cells[i].currentY == 0 && cells[i].currentZ == 0) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the up, left, and back face color of the buffer cell
    color bufferUpColor = #FFFFFF;
    color bufferLeftColor = #FFFFFF;
    color bufferBackColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == -1) // up face
        bufferUpColor = f.col;
      else if (f.dir.x == -1) // left face
        bufferLeftColor = f.col;
      else if (f.dir.z == -1) // back face
        bufferBackColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = -1;
    int swapCellY = -1;
    int swapCellZ = -1;

    if (bufferUpColor == #FF8D1A || bufferLeftColor == #FF8D1A || bufferBackColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferUpColor == #FF0000 || bufferLeftColor == #FF0000 || bufferBackColor == #FF0000)
      swapCellX = 2;
    
    if (bufferUpColor == #FFFFFF || bufferLeftColor == #FFFFFF || bufferBackColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferUpColor == #FFFF00 || bufferLeftColor == #FFFF00 || bufferBackColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferUpColor == #0000FF || bufferLeftColor == #0000FF || bufferBackColor == #0000FF)
      swapCellZ = 0;
    else if (bufferUpColor == #00FF00 || bufferLeftColor == #00FF00 || bufferBackColor == #00FF00)
      swapCellZ = 2;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferLeftColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferLeftColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferLeftColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferLeftColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferLeftColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getCornerSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // reversed setup moves to put back in it's original place
    ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--)
      reverseSetUpSequence.add(setUpSequence.get(i).invert());

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(MOD_Y_PERM_ALG)); 
    solveTurnSequence.addAll(reverseSetUpSequence);
  }
  
  private ArrayList<TurnAnimation> getEdgeSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;

    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // B face
          isBuffer = true;
        }
        else if (swapCellZ == 2) { // C face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 2) { // F face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // G face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 0) { // H face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // J face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // K face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('M', -1)); // M
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // L face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
          isBuffer = true;
        }
        else if (swapCellZ == 0) { // N face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // O face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellZ == 2) { // P face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('E', 1)); // E'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('M', 1)); // M'
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // R face
          setUpSequence.add(new TurnAnimation('L', -1)); // L
        }
        else if (swapCellY == 2) { // S face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('M', 1)); // M'
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // T face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('E', -1)); // E
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 2) { // U face
          setUpSequence.add(new TurnAnimation('D', 1)); // D'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 2) { // V face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellZ == 0) { // W face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
        else if (swapCellX == 0) { // X face
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {        
        for (int i = 1; i < cells.length; i++) { // first edge is at index 1
          if (cells[i].coloredFaces.size() == 2 && i != 19) { // only select an edge piece that is not the buffer
            if (cells[i].currentX != cells[i].solvedX || cells[i].currentY != cells[i].solvedY || cells[i].currentZ != cells[i].solvedZ ||
                cells[i].coloredFaces.get(0).dir.x != cells[i].coloredFaces.get(0).initialDir.x ||
                cells[i].coloredFaces.get(0).dir.y != cells[i].coloredFaces.get(0).initialDir.y) {
                  
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir = cells[i].coloredFaces.get(0).dir;
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  private void addParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', -1), // F'
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('F', 1), // F
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', 1), // R
      new TurnAnimation('U', 1), // U
      new TurnAnimation('U', 1), // U
      new TurnAnimation('R', -1), // R'
      new TurnAnimation('U', -1) // U'
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
  }
  
  private ArrayList<TurnAnimation> getCornerSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) {
          if (swapCellX == 0) { // A face
            isBuffer = true;
          }
          else if (swapCellX == 2) { // B face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
        else if (swapCellZ == 2) {
          if (swapCellX == 2) { // C face           
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
          else if (swapCellX == 0) { // D face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) {
          if (swapCellZ == 0) { // E face
            isBuffer = true;
          }
          else if (swapCellZ == 2) { // F face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
        else if (swapCellY == 2) {
          if (swapCellZ == 2) { // G face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellZ == 0) { // H face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) {
          if (swapCellX == 0) { // I face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
          else if (swapCellX == 2) { // J face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
        else if (swapCellY == 2) {
          if (swapCellX == 2) { // K face
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
          else if (swapCellX == 0) { // L face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('F', 1)); // F
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
          }
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) {
          if (swapCellZ == 2) { // M face
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 0) { // N face
            setUpSequence.add(new TurnAnimation('R', -1)); // R'
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
        else if (swapCellY == 2) {
          if (swapCellZ == 0) { // O face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
          else if (swapCellZ == 2) { // P face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('F', 1)); // F
          }
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) {
          if (swapCellX == 2) { // Q face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // R face
            isBuffer = true;
          }
        }
        else if (swapCellY == 2) {
          if (swapCellX == 0) { // S face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('F', -1)); // F'
          }
          else if (swapCellX == 2) { // T face
            setUpSequence.add(new TurnAnimation('R', 1)); // R
          }
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellX == 0 && swapCellZ == 2) { // U face
          setUpSequence.add(new TurnAnimation('D', -1)); // D
        }
        else if (swapCellZ == 0) {
          if (swapCellX == 2) { // W face
            setUpSequence.add(new TurnAnimation('D', 1)); // D'
          }
          else if (swapCellX == 0) { // X face
            setUpSequence.add(new TurnAnimation('D', -1)); // D
            setUpSequence.add(new TurnAnimation('D', -1)); // D
          }
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved piece
      if (isBuffer) {
        for (int i = 1; i < cells.length; i++) { // cannot swap with buffer again at index 0
          if (cells[i].coloredFaces.size() == 3) {
            if (cells[i].currentX != cells[i].solvedX || cells[i].currentY != cells[i].solvedY || cells[i].currentZ != cells[i].solvedZ ||
                cells[i].coloredFaces.get(0).dir.x != cells[i].coloredFaces.get(0).initialDir.x ||
                cells[i].coloredFaces.get(0).dir.y != cells[i].coloredFaces.get(0).initialDir.y) {
                  
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir = cells[i].coloredFaces.get(0).dir;
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
}
