import { describe, expect, it } from "vitest";
import { isAdminRole } from "./roles";

describe("isAdminRole", () => {
  it("accepts admin and super_admin", () => {
    expect(isAdminRole("admin")).toBe(true);
    expect(isAdminRole("super_admin")).toBe(true);
  });

  it("rejects non-admin roles", () => {
    expect(isAdminRole("investor")).toBe(false);
    expect(isAdminRole("moderator")).toBe(false);
    expect(isAdminRole("instructor")).toBe(false);
    expect(isAdminRole("community_manager")).toBe(false);
  });

  it("rejects null and undefined", () => {
    expect(isAdminRole(null)).toBe(false);
    expect(isAdminRole(undefined)).toBe(false);
  });
});
