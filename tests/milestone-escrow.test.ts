import { describe, it, expect, beforeEach } from "vitest"

type Project = {
  researcher: string
  totalFunding: bigint
  milestones: number
  validated: number
  released: bigint
}

const mockContract = {
  admin: "ST1ADMIN...",
  projects: new Map<number, Project>(),
  contributions: new Map<string, bigint>(),
  approvals: new Set<string>(),
  claimed: new Set<string>(),
  validators: new Set<string>(),

  makeKey(pid: number, mid: number) {
    return `${pid}::${mid}`
  },

  createProject(caller: string, id: number, researcher: string, milestones: number) {
    if (caller !== this.admin) return { error: 100 }
    this.projects.set(id, { researcher, totalFunding: 0n, milestones, validated: 0, released: 0n })
    return { value: true }
  },

  contribute(projectId: number, caller: string, amount: bigint) {
    if (!this.projects.has(projectId) || amount <= 0n) return { error: 101 }
    const key = `${projectId}::${caller}`
    this.contributions.set(key, (this.contributions.get(key) || 0n) + amount)
    const project = this.projects.get(projectId)!
    project.totalFunding += amount
    return { value: true }
  },

  assignValidator(caller: string, pid: number, mid: number, validator: string) {
    if (caller !== this.admin) return { error: 100 }
    this.validators.add(`${pid}::${mid}::${validator}`)
    return { value: true }
  },

  approveMilestone(caller: string, pid: number, mid: number) {
    const key = this.makeKey(pid, mid)
    if (!this.validators.has(`${pid}::${mid}::${caller}`)) return { error: 104 }
    if (this.approvals.has(key)) return { error: 103 }
    this.approvals.add(key)
    const project = this.projects.get(pid)!
    project.validated += 1
    return { value: true }
  },

  claimMilestone(caller: string, pid: number, mid: number) {
    const key = this.makeKey(pid, mid)
    const project = this.projects.get(pid)
    if (!project) return { error: 101 }
    if (caller !== project.researcher) return { error: 105 }
    if (!this.approvals.has(key)) return { error: 106 }
    if (this.claimed.has(key)) return { error: 103 }
    this.claimed.add(key)
    const perMilestone = project.totalFunding / BigInt(project.milestones)
    project.released += perMilestone
    return { value: perMilestone }
  }
}

describe("Milestone Escrow Contract", () => {
  beforeEach(() => {
    mockContract.projects.clear()
    mockContract.claimed.clear()
    mockContract.approvals.clear()
    mockContract.contributions.clear()
    mockContract.validators.clear()
  })

  it("creates a project", () => {
    const result = mockContract.createProject(mockContract.admin, 1, "ST2RESEARCHER...", 5)
    expect(result).toEqual({ value: true })
  })

  it("allows contributions", () => {
    mockContract.createProject(mockContract.admin, 1, "ST2R...", 5)
    const result = mockContract.contribute(1, "ST3FUND...", 100_000n)
    expect(result).toEqual({ value: true })
  })

  it("assigns and approves milestone", () => {
    mockContract.createProject(mockContract.admin, 1, "ST2R...", 5)
    mockContract.assignValidator(mockContract.admin, 1, 0, "ST4VALIDATOR...")
    const result = mockContract.approveMilestone("ST4VALIDATOR...", 1, 0)
    expect(result).toEqual({ value: true })
  })

  it("claims milestone funding", () => {
    mockContract.createProject(mockContract.admin, 1, "ST2R...", 2)
    mockContract.contribute(1, "ST3FUND...", 200_000n)
    mockContract.assignValidator(mockContract.admin, 1, 0, "ST4VALIDATOR...")
    mockContract.approveMilestone("ST4VALIDATOR...", 1, 0)
    const result = mockContract.claimMilestone("ST2R...", 1, 0)
    expect(result).toEqual({ value: 100_000n })
  })

  it("prevents duplicate claims", () => {
    mockContract.createProject(mockContract.admin, 1, "ST2R...", 2)
    mockContract.contribute(1, "ST3FUND...", 200_000n)
    mockContract.assignValidator(mockContract.admin, 1, 0, "ST4VALIDATOR...")
    mockContract.approveMilestone("ST4VALIDATOR...", 1, 0)
    mockContract.claimMilestone("ST2R...", 1, 0)
    const result = mockContract.claimMilestone("ST2R...", 1, 0)
    expect(result).toEqual({ error: 103 })
  })
})
