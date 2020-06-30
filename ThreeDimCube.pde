class ThreeDimCube extends Cube {  
  /*
  Phase 1: Align white center to top
  Phase 2: Align green center to front
  Phase 3: Solve all edge pieces with M2 method
  Phase 4: Solve all corner pieces with Modified Y Perm Algorithm
  */
  private int solvePhase;
  
  // counter to determine if parity is needed after solving edges
  private int edgeSwapCount;
  
  // constructor
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
      if (!areEdgesFixed())
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
  
  // align the white center cell to the top
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
  
  // align the green center cell to the front
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
  
  private boolean areEdgesFixed() {
    // counter to determine how many cells in the M slice are unsolved of flipped
    int parityCounter = 0;
    
    // loop through all edge pieces to see if any are in the incorrect position
    for (Cell c : cells) {
      // only check the edge pieces
      if (c.coloredFaces.size() == 2) {
        // if the cell is in the incorrect position or flipped
        if (!c.isSolved()) {
            // Parity
            if (edgeSwapCount % 2 == 1) {
              // allow for 2 cells to be off in the M slice
              if (c.currentX == 1)
                parityCounter++;
              else
                return false;
            }
            else { // if NOT parity, then all should be solved
              return false;
            }
        }
      }
    }
    
    // if less than 2 cells are off in the M slice, then the edges are fixed
    if (parityCounter > 2)
      return false;
    else
      return true;
  }
  
  private void solveEdge() {
    // M2 Swap Algorithm
    final TurnAnimation[] M2_SWAP_ALG = {
      new TurnAnimation('M', 1), // M'
      new TurnAnimation('M', 1) // M'
    };
    
    // getting the buffer cell's index in the array of all cells
    int bufferIndex = -1;

    for (int i = 1; i < (cells.length - 1); i++) { // first edge is at index 1 and last is at cells.length - 1
      if (cells[i].currentX == 1 && cells[i].currentY == 2 && cells[i].currentZ == 2) {
        bufferIndex = i;
        break;
      }
    }
    
    // getting the down and front face color of the buffer cell
    color bufferDownColor = #FFFFFF;
    color bufferFrontColor = #FFFFFF;
    
    for (Face f : cells[bufferIndex].coloredFaces) {
      if (f.dir.y == 1) // down face
         bufferDownColor = f.col;
      else if (f.dir.z == 1) // front face
         bufferFrontColor = f.col;
    }
    
    // find where the buffer needs to go
    int swapCellX = 1;
    int swapCellY = 1;
    int swapCellZ = 1;

    if (bufferDownColor == #FF8D1A || bufferFrontColor == #FF8D1A)
      swapCellX = 0;
    else if (bufferDownColor == #FF0000 || bufferFrontColor == #FF0000)
      swapCellX = 2;
    
    if (bufferDownColor == #FFFFFF || bufferFrontColor == #FFFFFF)
      swapCellY = 0;
    else if (bufferDownColor == #FFFF00 || bufferFrontColor == #FFFF00)
      swapCellY = 2;
    
    if (bufferDownColor == #0000FF || bufferFrontColor == #0000FF)
      swapCellZ = 0;
    else if (bufferDownColor == #00FF00 || bufferFrontColor == #00FF00)
      swapCellZ = 2;
    
    // find the direction that the buffer needs to be
    PVector swapCellDir;
    
    if (bufferDownColor == #FF8D1A)
      swapCellDir = new PVector(-1, 0, 0);
    else if (bufferDownColor == #FF0000)
       swapCellDir = new PVector(1, 0, 0);
    else if (bufferDownColor == #FFFFFF)
      swapCellDir = new PVector(0, -1, 0);
    else if (bufferDownColor == #FFFF00)
      swapCellDir = new PVector(0, 1, 0);
    else if (bufferDownColor == #0000FF)
      swapCellDir = new PVector(0, 0, -1);
    else // #00FF00
      swapCellDir = new PVector(0, 0, 1);
    
    // increment the edge swap counter
    edgeSwapCount++;
    
    // get the setup moves for that specific face
    ArrayList<TurnAnimation> setUpSequence = getEdgeSetupMoves(swapCellX, swapCellY, swapCellZ, swapCellDir);

    // if no setup moves are needed or a special case, then do nothing
    if (setUpSequence.size() != 0) {
      // reversed setup moves to put back in it's original place
      ArrayList<TurnAnimation> reverseSetUpSequence = new ArrayList<TurnAnimation>();
    
      for (int i = setUpSequence.size() - 1; i >= 0; i--) {
        char notationBase = setUpSequence.get(i).getNotationBase();
        int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
        reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
      }
      
      // add all turns to the solve sequence
      solveTurnSequence.addAll(setUpSequence);
      solveTurnSequence.addAll(Arrays.asList(M2_SWAP_ALG));
      solveTurnSequence.addAll(reverseSetUpSequence);
    }
  }
  
  private ArrayList<TurnAnimation> getEdgeSetupMoves(int swapCellX, int swapCellY, int swapCellZ, PVector swapCellDir) {
    ArrayList<TurnAnimation> setUpSequence = new ArrayList<TurnAnimation>();
    
    /*
      When swap is the 2nd letter of a pair and it is a special face
      in the M slice (C, W, I, S), then swap with the opposite face instead
    */
    if (edgeSwapCount % 2 == 0) {
      if (swapCellDir.y == -1 && swapCellZ == 2) { // C face to W Face
        swapCellDir.y = 1;
        swapCellY = 2;
        swapCellZ = 0;
      }
      else if (swapCellDir.y == 1 && swapCellZ == 0) { // W face to C Face
        swapCellDir.y = -1;
        swapCellY = 0;
        swapCellZ = 2;
      }
      else if (swapCellDir.z == 1 && swapCellY == 0) { // I Face to S Face
        swapCellDir.z = -1;
        swapCellY = 2;
        swapCellZ = 0;
      }
      else if (swapCellDir.z == -1 && swapCellY == 2) { // S Face to I Face
        swapCellDir.z = 1;
        swapCellY = 0;
        swapCellZ = 2;
      }
    }
    
    // rare case when the swap cell is also the buffer
    boolean isBuffer;
    
    do {
      isBuffer = false;
      
      if (swapCellDir.y == -1) {
        if (swapCellZ == 0) { // A face
        println("A");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        }
        else if (swapCellX == 2) { // B face
        println("B");
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 2) { // C face
        println("C");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
        }
        else if (swapCellX == 0) { // D face
        println("D");
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == -1) {
        if (swapCellY == 0) { // E face
        println("E");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 2) { // F face
        println("F");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellY == 2) { // G face
        println("G");
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }
        else if (swapCellZ == 0) { // H face
        println("H");
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('B', -1)); // B
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
        }      
      }
      else if (swapCellDir.z == 1) {
        if (swapCellY == 0) { // I face
        println("I");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('D', -1)); // D
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
        }
        else if (swapCellX == 2) { // J face
        println("J");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellY == 2) { // K face
        println("K");
          isBuffer = true;
        }
        else if (swapCellX == 0) { // L face
        println("L");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', 1)); // L'
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      else if (swapCellDir.x == 1) {
        if (swapCellY == 0) { // M face
        println("M");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 0) { // N face
        println("N");
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellY == 2) { // O face
        println("O");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
        else if (swapCellZ == 2) { // P face
        println("P");
          setUpSequence.add(new TurnAnimation('B', 1)); // B'
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('B', -1)); // B
        }
      }
      else if (swapCellDir.z == -1) {
        if (swapCellY == 0) { // Q face
        println("Q");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('B', -1)); // B
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('B', 1)); // B'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', -1)); // R'
          solveTurnSequence.add(new TurnAnimation('B', -1)); // B
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellX == 0) { // R face
        println("R");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
        else if (swapCellY == 2) { // S face
        println("S");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('D', -1)); // D
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', 1)); // M'
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('R', 1)); // R
          solveTurnSequence.add(new TurnAnimation('U', -1)); // U'
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('D', 1)); // D'
        }
        else if (swapCellX == 2) { // T face
        println("T");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', -1)); // R'
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
      }
      else { // swapCellDir.y == 1
        if (swapCellZ == 2) { // U face
        println("U");
          isBuffer = true;
        }
        else if (swapCellX == 2) { // V face
        println("V");
          setUpSequence.add(new TurnAnimation('U', 1)); // U
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('R', 1)); // R
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
        }
        else if (swapCellZ == 0) { // W face
        println("W");
          // special case - add directly to solve sequence
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
          solveTurnSequence.add(new TurnAnimation('U', 1)); // U
        }
        else if (swapCellX == 0) { // X face
        println("X");
          setUpSequence.add(new TurnAnimation('U', -1)); // U'
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('L', -1)); // L
          setUpSequence.add(new TurnAnimation('U', 1)); // U
        }
      }
      
      // if the swap cell is the buffer, then pick any unsolved or flipped piece
      if (isBuffer) {
        
        // first edge is at index 1 and last is at cells.length - 1
        for (int i = 1; i < cells.length - 1; i++) {
          // only check the edge pieces and don't allow for the new cell to be the buffer
          if (cells[i].coloredFaces.size() == 2 && i != 17) {
            // if the cell is in the incorrect position or flipped
            if (!cells[i].isSolved()) {
              swapCellX = cells[i].currentX;
              swapCellY = cells[i].currentY;
              swapCellZ = cells[i].currentZ;
              
              swapCellDir.x = cells[i].coloredFaces.get(0).dir.x;
              swapCellDir.y = cells[i].coloredFaces.get(0).dir.y;
              swapCellDir.z = cells[i].coloredFaces.get(0).dir.z;
              
              // if new swap cell is in the M slice, continue looking
              if (swapCellX != 1)
                break;
            }
          }
        }
                
        if (swapCellX == 1 && edgeSwapCount % 2 == 0) {
          
          // W Y Y B B G : NEED
          
          // B Y Y B B G : GOT
          // ? Y Y B B Y : GOT
          
          println(edgeSwapCount); //<>//
          
          //addParityAlgorithm();
          
          //solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          //solveTurnSequence.add(new TurnAnimation('M', -1)); // M
          //addParityAlgorithm();
          
          return setUpSequence;
        }
        
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
  
  private void addParityAlgorithm() {
    // Parity Algorithm
    final TurnAnimation[] PARITY_ALG = {
      new TurnAnimation('D', 1), // D'
      new TurnAnimation('L', -1), // L
      new TurnAnimation('L', -1), // L
      new TurnAnimation('D', -1), // D
      new TurnAnimation('M', -1), // M
      new TurnAnimation('M', -1), // M
      new TurnAnimation('D', 1), // D'
      new TurnAnimation('L', -1), // L
      new TurnAnimation('L', -1), // L
      new TurnAnimation('D', -1) // D
    };
    
    solveTurnSequence.addAll(Arrays.asList(PARITY_ALG));
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
    
    for (int i = setUpSequence.size() - 1; i >= 0; i--) {
      char notationBase = setUpSequence.get(i).getNotationBase();
      int invertedDirValue = setUpSequence.get(i).getDirValue() * -1;
      reverseSetUpSequence.add(new TurnAnimation(notationBase, invertedDirValue));
    }

    // add all turns to the solve sequence
    solveTurnSequence.addAll(setUpSequence);
    solveTurnSequence.addAll(Arrays.asList(MOD_Y_PERM_ALG)); 
    solveTurnSequence.addAll(reverseSetUpSequence);
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
      
      // if the swap cell is the buffer, then pick any unsolved or flipped piece
      if (isBuffer) {
        // don't allow for the new cell to be the buffer at index 0
        for (int i = 1; i < cells.length; i++) {
          // only check the corner pieces
          if (cells[i].coloredFaces.size() == 3) {
            // if the cell is in the incorrect position or flipped
            if (!cells[i].isSolved()) {
                swapCellX = cells[i].currentX;
                swapCellY = cells[i].currentY;
                swapCellZ = cells[i].currentZ;
                
                swapCellDir.x = cells[i].coloredFaces.get(0).dir.x;
                swapCellDir.y = cells[i].coloredFaces.get(0).dir.y;
                swapCellDir.z = cells[i].coloredFaces.get(0).dir.z;
                
                break;
            }
          }
        }
      }
    } while (isBuffer);
    
    return setUpSequence;
  }
}
