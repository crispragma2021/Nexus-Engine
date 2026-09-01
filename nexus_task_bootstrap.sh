#!/usr/bin/env bash
set -e

SANDBOX_BRANCH="sandbox/bootstrap_core_ecs"
LOG_FILE="nexus_daemon.log"

git checkout -b "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1

cleanup() {
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [ERROR] Fallo en la tarea. Revertiendo sandbox..." >> "$LOG_FILE"
  git checkout - >> "$LOG_FILE" 2>&1 || git checkout main >> "$LOG_FILE" 2>&1
  git branch -D "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1
  exit 1
}
trap cleanup ERR

# Crear módulo base de ECS en Rust si no existe
mkdir -p src/ecs
cat << 'RUST_EOF' > src/ecs/mod.rs
pub type EntityId = u64;

#[derive(Debug, Clone, PartialEq)]
pub struct Transform2D {
    pub x: f32,
    pub y: f32,
    pub rotation: f32,
}

impl Default for Transform2D {
    fn default() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            rotation: 0.0,
        }
    }
}

pub struct World {
    next_id: EntityId,
    pub transforms: std::collections::HashMap<EntityId, Transform2D>,
}

impl World {
    pub fn new() -> Self {
        Self {
            next_id: 1,
            transforms: std::collections::HashMap::new(),
        }
    }

    pub fn spawn_entity(&mut self, transform: Transform2D) -> EntityId {
        let id = self.next_id;
        self.next_id += 1;
        self.transforms.insert(id, transform);
        id
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_spawn_entity() {
        let mut world = World::new();
        let entity = world.spawn_entity(Transform2D { x: 10.0, y: 20.0, rotation: 0.0 });
        assert_eq!(entity, 1);
        assert_eq!(world.transforms.get(&entity).unwrap().x, 10.0);
    }
}
RUST_EOF

# Registrar módulo en lib.rs o main.rs
if [ -f "src/lib.rs" ]; then
  if ! grep -q "pub mod ecs;" src/lib.rs; then
    echo "pub mod ecs;" >> src/lib.rs
  fi
elif [ -f "src/main.rs" ]; then
  if ! grep -q "mod ecs;" src/main.rs; then
    sed -i '1s/^/mod ecs;\n/' src/main.rs
  fi
fi

# Validar compilación y tests
cargo check --quiet >> "$LOG_FILE" 2>&1
cargo test --quiet >> "$LOG_FILE" 2>&1

# Sincronizar rama de vuelta si todo es exitoso
git add src/
git commit -m "feat(ecs): implementar estructura base de World y Transform2D" >> "$LOG_FILE" 2>&1
git checkout - >> "$LOG_FILE" 2>&1 || git checkout main >> "$LOG_FILE" 2>&1
git merge --ff-only "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1
git branch -d "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SUCCESS] Módulo ECS integrado y validado con tests." >> "$LOG_FILE"
